//
//  AsepriteManager.swift
//  PixelMe
//
//  .aseprite 파일 가져오기/내보내기 지원
//  Aseprite 파일 형식 참고: https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md
//

import Foundation
import UIKit

/// Aseprite 파일 매니저
final class AsepriteManager {

    enum AseError: LocalizedError {
        case invalidMagic
        case unsupportedVersion
        case invalidData
        case exportFailed

        var errorDescription: String? {
            switch self {
            case .invalidMagic: return "Invalid Aseprite file format."
            case .unsupportedVersion: return "Unsupported Aseprite version."
            case .invalidData: return "Corrupted file data."
            case .exportFailed: return "Failed to export Aseprite file."
            }
        }
    }

    // MARK: - Import

    /// .aseprite/.ase 파일에서 프레임들을 읽어옴
    static func importFile(from url: URL) throws -> (width: Int, height: Int, frames: [AnimationFrame]) {
        let data = try Data(contentsOf: url)
        guard data.count >= 128 else { throw AseError.invalidData }

        // Header (128 bytes)
        let magic = data.readUInt16(at: 4)
        guard magic == 0xA5E0 else { throw AseError.invalidMagic }

        let frameCount = Int(data.readUInt16(at: 6))
        let width = Int(data.readUInt16(at: 8))
        let height = Int(data.readUInt16(at: 10))
        let colorDepth = Int(data.readUInt16(at: 12))  // 32=RGBA, 16=Grayscale, 8=Indexed

        guard width > 0, width <= 512, height > 0, height <= 512 else { throw AseError.invalidData }

        var frames: [AnimationFrame] = []
        var offset = 128  // Header size

        for _ in 0..<frameCount {
            guard offset + 16 <= data.count else { break }

            let frameSize = Int(data.readUInt32(at: offset))
            let frameMagic = data.readUInt16(at: offset + 4)
            let chunkCount = Int(data.readUInt16(at: offset + 6))
            let durationMs = Int(data.readUInt16(at: offset + 8))

            guard frameMagic == 0xF1FA else { break }

            // 간단한 구현: 프레임당 하나의 레이어로 처리
            var layer = PixelLayer(name: "Frame \(frames.count + 1)", width: width, height: height)

            // 각 청크 파싱 (셀 데이터만 처리)
            var chunkOffset = offset + 16
            for _ in 0..<chunkCount {
                guard chunkOffset + 6 <= data.count else { break }
                let chunkSize = Int(data.readUInt32(at: chunkOffset))
                let chunkType = data.readUInt16(at: chunkOffset + 4)

                // 0x2005 = Cel Chunk (raw pixel data)
                if chunkType == 0x2005 && chunkOffset + 20 <= data.count {
                    let celType = data.readUInt16(at: chunkOffset + 13)
                    if celType == 0 { // Raw cel
                        let celW = Int(data.readUInt16(at: chunkOffset + 15))
                        let celH = Int(data.readUInt16(at: chunkOffset + 17))
                        let pixelStart = chunkOffset + 19
                        let bytesPerPixel = colorDepth / 8

                        for y in 0..<min(celH, height) {
                            for x in 0..<min(celW, width) {
                                let pixOffset = pixelStart + (y * celW + x) * bytesPerPixel
                                guard pixOffset + bytesPerPixel <= data.count else { continue }

                                let color: PixelColor
                                if colorDepth == 32 {
                                    color = PixelColor(
                                        r: data[pixOffset],
                                        g: data[pixOffset + 1],
                                        b: data[pixOffset + 2],
                                        a: data[pixOffset + 3]
                                    )
                                } else if colorDepth == 8 {
                                    let v = data[pixOffset]
                                    color = PixelColor(r: v, g: v, b: v)
                                } else {
                                    continue
                                }
                                if !color.isTransparent {
                                    layer.canvas.setPixel(at: PixelPoint(x: x, y: y), color: color)
                                }
                            }
                        }
                    }
                }

                chunkOffset += max(chunkSize, 6)
            }

            let frame = AnimationFrame(layers: [layer], durationMs: max(durationMs, 16))
            frames.append(frame)
            offset += max(frameSize, 16)
        }

        if frames.isEmpty {
            // 파싱 실패 시 빈 프레임 생성
            frames = [AnimationFrame(width: width, height: height)]
        }

        return (width, height, frames)
    }

    // MARK: - Export

    /// 프레임들을 .aseprite 형식으로 내보내기
    static func exportFile(width: Int, height: Int, frames: [AnimationFrame]) throws -> Data {
        var data = Data()

        // --- Header (128 bytes) ---
        data.appendUInt32(0)        // File size (patch later)
        data.appendUInt16(0xA5E0)   // Magic
        data.appendUInt16(UInt16(frames.count))
        data.appendUInt16(UInt16(width))
        data.appendUInt16(UInt16(height))
        data.appendUInt16(32)       // Color depth: RGBA
        data.appendUInt32(0)        // Flags
        data.appendUInt16(100)      // Speed (deprecated)
        data.appendUInt32(0)        // Reserved
        data.appendUInt32(0)        // Reserved
        data.append(UInt8(0))       // Transparent index
        data.append(contentsOf: [UInt8](repeating: 0, count: 3)) // Ignore
        data.appendUInt16(0)        // Color count
        data.append(UInt8(0))       // Pixel width
        data.append(UInt8(0))       // Pixel height
        data.appendUInt16(0)        // Grid X
        data.appendUInt16(0)        // Grid Y
        data.appendUInt16(0)        // Grid width
        data.appendUInt16(0)        // Grid height
        // Pad to 128 bytes
        let headerSoFar = data.count
        if headerSoFar < 128 {
            data.append(contentsOf: [UInt8](repeating: 0, count: 128 - headerSoFar))
        }

        // --- Frames ---
        for frame in frames {
            var frameData = Data()

            // Frame header
            frameData.appendUInt32(0)           // Frame size (patch later)
            frameData.appendUInt16(0xF1FA)      // Magic
            frameData.appendUInt16(1)           // Number of chunks (1 cel)
            frameData.appendUInt16(UInt16(frame.durationMs))
            frameData.append(contentsOf: [UInt8](repeating: 0, count: 6)) // Reserved

            // Cel chunk
            var celData = Data()
            celData.appendUInt32(0)     // Chunk size (patch later)
            celData.appendUInt16(0x2005) // Cel chunk type
            celData.appendUInt16(0)     // Layer index
            celData.appendUInt16(0)     // X position
            celData.appendUInt16(0)     // Y position
            celData.append(UInt8(255))  // Opacity
            celData.appendUInt16(0)     // Cel type: Raw
            celData.appendUInt16(UInt16(width))
            celData.appendUInt16(UInt16(height))
            celData.append(contentsOf: [UInt8](repeating: 0, count: 1)) // zero filler

            // Pixel data (RGBA)
            let merged = mergeFrameLayers(frame, width: width, height: height)
            for y in 0..<height {
                for x in 0..<width {
                    let color = merged.pixel(at: PixelPoint(x: x, y: y)) ?? .clear
                    celData.append(color.r)
                    celData.append(color.g)
                    celData.append(color.b)
                    celData.append(color.a)
                }
            }

            // Patch cel chunk size
            let celSize = UInt32(celData.count)
            celData.replaceSubrange(0..<4, with: withUnsafeBytes(of: celSize.littleEndian) { Data($0) })

            frameData.append(celData)

            // Patch frame size
            let frameSize = UInt32(frameData.count)
            frameData.replaceSubrange(0..<4, with: withUnsafeBytes(of: frameSize.littleEndian) { Data($0) })

            data.append(frameData)
        }

        // Patch total file size
        let totalSize = UInt32(data.count)
        data.replaceSubrange(0..<4, with: withUnsafeBytes(of: totalSize.littleEndian) { Data($0) })

        return data
    }

    private static func mergeFrameLayers(_ frame: AnimationFrame, width: Int, height: Int) -> PixelCanvas {
        var merged = PixelCanvas(width: width, height: height)
        for layer in frame.layers where layer.isVisible {
            for y in 0..<height {
                for x in 0..<width {
                    let p = PixelPoint(x: x, y: y)
                    if let color = layer.canvas.pixel(at: p), !color.isTransparent {
                        merged.setPixel(at: p, color: color)
                    }
                }
            }
        }
        return merged
    }
}

// MARK: - Data Extensions for Binary Read/Write

private extension Data {
    func readUInt16(at offset: Int) -> UInt16 {
        guard offset + 2 <= count else { return 0 }
        return withUnsafeBytes { $0.load(fromByteOffset: offset, as: UInt16.self) }
    }

    func readUInt32(at offset: Int) -> UInt32 {
        guard offset + 4 <= count else { return 0 }
        return withUnsafeBytes { $0.load(fromByteOffset: offset, as: UInt32.self) }
    }

    mutating func appendUInt16(_ value: UInt16) {
        var v = value.littleEndian
        append(Data(bytes: &v, count: 2))
    }

    mutating func appendUInt32(_ value: UInt32) {
        var v = value.littleEndian
        append(Data(bytes: &v, count: 4))
    }
}
