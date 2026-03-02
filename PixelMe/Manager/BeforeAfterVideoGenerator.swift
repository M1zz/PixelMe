//
//  BeforeAfterVideoGenerator.swift
//  PixelMe
//
//  Before/After 전환 애니메이션 비디오 생성 (릴스/틱톡용)
//

import AVFoundation
import UIKit

/// 비포/애프터 전환 비디오를 생성하는 매니저
/// 릴스/틱톡 세로 포맷(1080×1920)으로 MP4 출력
class BeforeAfterVideoGenerator {

    // MARK: - Types

    enum VideoError: LocalizedError {
        case writerSetupFailed
        case inputSetupFailed
        case pixelBufferFailed
        case writingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .writerSetupFailed: return "Failed to set up video writer."
            case .inputSetupFailed: return "Failed to set up video input."
            case .pixelBufferFailed: return "Failed to create pixel buffer."
            case .writingFailed(let error): return "Video writing failed: \(error.localizedDescription)"
            }
        }
    }

    /// 비디오 출력 포맷
    enum VideoFormat {
        case reels      // 1080×1920 (9:16)
        case square     // 1080×1080 (1:1)
        case landscape  // 1920×1080 (16:9)

        var size: CGSize {
            switch self {
            case .reels:     return CGSize(width: 1080, height: 1920)
            case .square:    return CGSize(width: 1080, height: 1080)
            case .landscape: return CGSize(width: 1920, height: 1080)
            }
        }
    }

    // MARK: - Constants

    private static let fps: Int32 = 30
    private static let totalDurationSeconds: Double = 3.0

    // MARK: - Public API

    /// Before/After 전환 비디오 생성
    /// - Parameters:
    ///   - original: 원본 이미지
    ///   - pixelated: 픽셀화된 이미지
    ///   - format: 출력 포맷 (기본: reels 9:16)
    ///   - completion: 생성된 비디오 URL 또는 에러
    @MainActor
    static func generate(
        original: UIImage,
        pixelated: UIImage,
        format: VideoFormat = .reels,
        completion: @escaping (Result<URL, VideoError>) -> Void
    ) {
        let isPro = SubscriptionManager.shared.isProUser
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let url = try createVideo(original: original, pixelated: pixelated, format: format, isPro: isPro)
                DispatchQueue.main.async { completion(.success(url)) }
            } catch let error as VideoError {
                DispatchQueue.main.async { completion(.failure(error)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.writingFailed(error))) }
            }
        }
    }

    // MARK: - Video Creation

    private static func createVideo(
        original: UIImage,
        pixelated: UIImage,
        format: VideoFormat,
        isPro: Bool
    ) throws -> URL {
        let outputSize = format.size
        let totalFrames = Int(totalDurationSeconds * Double(fps))

        // 출력 파일 준비
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("pixelme_beforeafter_\(Int(Date().timeIntervalSince1970)).mp4")
        try? FileManager.default.removeItem(at: outputURL)

        // AVAssetWriter 설정
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch {
            throw VideoError.writerSetupFailed
        }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(outputSize.width),
            AVVideoHeightKey: Int(outputSize.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 8_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerInput.expectsMediaDataInRealTime = false

        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: Int(outputSize.width),
            kCVPixelBufferHeightKey as String: Int(outputSize.height)
        ]

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )

        guard writer.canAdd(writerInput) else { throw VideoError.inputSetupFailed }
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        // 이미지를 비디오 프레임 크기에 맞게 준비
        let originalFrame = fitImageToFrame(original, outputSize: outputSize)
        let pixelatedFrame = fitImageToFrame(pixelated, outputSize: outputSize)

        // 프레임 생성 & 쓰기
        for frameIndex in 0..<totalFrames {
            while !writerInput.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.01)
            }

            let progress = Double(frameIndex) / Double(totalFrames)
            let frameImage = compositeFrame(
                original: originalFrame,
                pixelated: pixelatedFrame,
                progress: progress,
                outputSize: outputSize,
                isPro: isPro
            )

            guard let pixelBuffer = pixelBufferFrom(image: frameImage, size: outputSize) else {
                throw VideoError.pixelBufferFailed
            }

            let presentationTime = CMTime(value: CMTimeValue(frameIndex), timescale: fps)
            adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }

        writerInput.markAsFinished()

        let semaphore = DispatchSemaphore(value: 0)
        var writeError: Error?
        writer.finishWriting {
            if writer.status == .failed {
                writeError = writer.error
            }
            semaphore.signal()
        }
        semaphore.wait()

        if let error = writeError {
            throw VideoError.writingFailed(error)
        }

        return outputURL
    }

    // MARK: - Frame Composition

    /// 진행도에 따라 Before→After 전환 프레임 생성
    /// 0.0~0.33: 원본 표시
    /// 0.33~0.66: 크로스페이드 전환
    /// 0.66~1.0: 픽셀 결과 표시
    private static func compositeFrame(
        original: UIImage,
        pixelated: UIImage,
        progress: Double,
        outputSize: CGSize,
        isPro: Bool
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: outputSize)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: outputSize)

            // 배경
            UIColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1.0).setFill()
            context.fill(rect)

            // 전환 알파 계산
            let alpha: CGFloat
            if progress < 0.33 {
                alpha = 0.0 // 원본만
            } else if progress < 0.66 {
                alpha = CGFloat((progress - 0.33) / 0.33) // 크로스페이드
            } else {
                alpha = 1.0 // 픽셀만
            }

            // 원본 이미지
            original.draw(in: rect, blendMode: .normal, alpha: 1.0 - alpha)

            // 픽셀 이미지 (오버레이)
            pixelated.draw(in: rect, blendMode: .normal, alpha: alpha)

            // 하단 브랜딩 오버레이
            drawBranding(in: rect, progress: progress, isPro: isPro)

            // 상단 상태 라벨
            drawStatusLabel(in: rect, progress: progress)
        }
    }

    /// 하단 브랜딩: "Made with PixelMe"
    private static func drawBranding(in rect: CGRect, progress: Double, isPro: Bool) {
        let brandingHeight: CGFloat = 60
        let brandingRect = CGRect(
            x: 0,
            y: rect.height - brandingHeight,
            width: rect.width,
            height: brandingHeight
        )

        // 그라데이션 배경
        UIColor.black.withAlphaComponent(0.5).setFill()
        UIRectFill(brandingRect)

        let brandText = isPro ? "PixelMe" : "Made with PixelMe"
        let brandAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        let brandSize = (brandText as NSString).size(withAttributes: brandAttributes)

        if isPro {
            let brandPoint = CGPoint(
                x: (rect.width - brandSize.width) / 2,
                y: rect.height - brandingHeight + (brandingHeight - brandSize.height) / 2
            )
            (brandText as NSString).draw(at: brandPoint, withAttributes: brandAttributes)
        } else {
            let linkText = "apps.apple.com/app/pixel-meme"
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let linkSize = (linkText as NSString).size(withAttributes: linkAttributes)

            let totalHeight = brandSize.height + 2 + linkSize.height
            let startY = rect.height - brandingHeight + (brandingHeight - totalHeight) / 2

            let brandPoint = CGPoint(x: (rect.width - brandSize.width) / 2, y: startY)
            (brandText as NSString).draw(at: brandPoint, withAttributes: brandAttributes)

            let linkPoint = CGPoint(x: (rect.width - linkSize.width) / 2, y: startY + brandSize.height + 2)
            (linkText as NSString).draw(at: linkPoint, withAttributes: linkAttributes)
        }
    }

    /// 상단 상태 라벨: "Before" / "After"
    private static func drawStatusLabel(in rect: CGRect, progress: Double) {
        let labelText: String
        let labelAlpha: CGFloat

        if progress < 0.30 {
            labelText = "Before"
            labelAlpha = 0.9
        } else if progress < 0.36 {
            // Before 페이드아웃
            labelText = "Before"
            labelAlpha = CGFloat(1.0 - (progress - 0.30) / 0.06) * 0.9
        } else if progress < 0.63 {
            // 전환 중
            labelText = ""
            labelAlpha = 0
        } else if progress < 0.70 {
            // After 페이드인
            labelText = "After ✨"
            labelAlpha = CGFloat((progress - 0.63) / 0.07) * 0.9
        } else {
            labelText = "After ✨"
            labelAlpha = 0.9
        }

        guard !labelText.isEmpty, labelAlpha > 0 else { return }

        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor.white.withAlphaComponent(labelAlpha)
        ]
        let shadowAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor.black.withAlphaComponent(labelAlpha * 0.5)
        ]

        let labelSize = (labelText as NSString).size(withAttributes: labelAttributes)
        let labelPoint = CGPoint(
            x: (rect.width - labelSize.width) / 2,
            y: 60
        )

        // 그림자
        let shadowPoint = CGPoint(x: labelPoint.x + 1, y: labelPoint.y + 1)
        (labelText as NSString).draw(at: shadowPoint, withAttributes: shadowAttributes)

        // 텍스트
        (labelText as NSString).draw(at: labelPoint, withAttributes: labelAttributes)
    }

    // MARK: - Image Helpers

    /// 이미지를 출력 사이즈에 맞게 중앙 배치 (aspect fill)
    private static func fitImageToFrame(_ image: UIImage, outputSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        return renderer.image { _ in
            UIColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1.0).setFill()
            UIRectFill(CGRect(origin: .zero, size: outputSize))

            let imageAspect = image.size.width / image.size.height
            let frameAspect = outputSize.width / outputSize.height

            let drawRect: CGRect
            if imageAspect > frameAspect {
                // 이미지가 더 넓음 → 세로 기준으로 맞춤
                let height = outputSize.height * 0.7
                let width = height * imageAspect
                drawRect = CGRect(
                    x: (outputSize.width - width) / 2,
                    y: (outputSize.height - height) / 2,
                    width: width,
                    height: height
                )
            } else {
                // 이미지가 더 높음 → 가로 기준으로 맞춤
                let width = outputSize.width * 0.85
                let height = width / imageAspect
                drawRect = CGRect(
                    x: (outputSize.width - width) / 2,
                    y: (outputSize.height - height) / 2,
                    width: width,
                    height: height
                )
            }

            // 라운드 코너 클리핑
            let cornerPath = UIBezierPath(roundedRect: drawRect, cornerRadius: 16)
            cornerPath.addClip()
            image.draw(in: drawRect)
        }
    }

    /// UIImage → CVPixelBuffer 변환
    private static func pixelBufferFrom(image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return nil }

        guard let cgImage = image.cgImage else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        return buffer
    }
}
