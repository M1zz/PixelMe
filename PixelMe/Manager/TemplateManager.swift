//
//  TemplateManager.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI
import UIKit
import PhotosUI
import Photos
import Vision
import CoreImage

/// Template categories
enum TemplateCategory: String, CaseIterable, Identifiable {
    case profile = "Profile Picture"
    case pixelAvatar = "Pixel Avatar"
    case gameSprite = "Game Sprite"
    case icon = "App Icon"
    case banner = "Banner"
    case sticker = "Sticker"

    var id: String { rawValue }

    var templates: [Template] {
        switch self {
        case .profile:
            return Template.profileTemplates
        case .pixelAvatar:
            return Template.pixelAvatarTemplates
        case .gameSprite:
            return Template.gameSpriteTemplates
        case .icon:
            return Template.iconTemplates
        case .banner:
            return Template.bannerTemplates
        case .sticker:
            return Template.stickerTemplates
        }
    }
}

/// Template model
struct Template: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let size: CGSize
    let aspectRatio: CGFloat
    let pixelSize: Int
    let recommendedPalette: String?
    let hasBorder: Bool
    let borderColor: String?
    let borderWidth: CGFloat

    // Computed property for SwiftUI Color
    var borderUIColor: UIColor? {
        guard let hexString = borderColor else { return nil }
        return UIColor(hexString: hexString)
    }

    // MARK: - Profile Picture Templates
    static let profileTemplates: [Template] = [
        Template(
            id: "profile_square",
            name: "Square Profile",
            description: "Classic square profile picture",
            category: "profile",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "pastel",
            hasBorder: true,
            borderColor: "#FFFFFF",
            borderWidth: 8
        ),
        Template(
            id: "profile_circle",
            name: "Circle Profile",
            description: "Circular profile picture for social media",
            category: "profile",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "vaporwave",
            hasBorder: true,
            borderColor: "#FF71A6",
            borderWidth: 10
        ),
        Template(
            id: "profile_rounded",
            name: "Rounded Profile",
            description: "Rounded corners profile picture",
            category: "profile",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 12,
            recommendedPalette: "cyberpunk",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]

    // MARK: - NFT Avatar Templates
    static let pixelAvatarTemplates: [Template] = [
        Template(
            id: "nft_punk",
            name: "Punk Style",
            description: "CryptoPunks inspired 24x24 avatar",
            category: "nftAvatar",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 24,
            recommendedPalette: "retro8bit",
            hasBorder: true,
            borderColor: "#000000",
            borderWidth: 4
        ),
        Template(
            id: "nft_bored",
            name: "Ape Style",
            description: "BAYC inspired avatar",
            category: "nftAvatar",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "snes",
            hasBorder: true,
            borderColor: "#8B4513",
            borderWidth: 6
        ),
        Template(
            id: "nft_doodle",
            name: "Doodle Style",
            description: "Colorful doodle avatar",
            category: "nftAvatar",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 12,
            recommendedPalette: "pastel",
            hasBorder: true,
            borderColor: "#FFD700",
            borderWidth: 8
        )
    ]

    // MARK: - Game Sprite Templates
    static let gameSpriteTemplates: [Template] = [
        Template(
            id: "sprite_character",
            name: "Character Sprite",
            description: "16x16 game character",
            category: "gameSprite",
            size: CGSize(width: 256, height: 256),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "nes",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "sprite_item",
            name: "Item Sprite",
            description: "8x8 game item",
            category: "gameSprite",
            size: CGSize(width: 128, height: 128),
            aspectRatio: 1.0,
            pixelSize: 8,
            recommendedPalette: "gameboy",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "sprite_enemy",
            name: "Enemy Sprite",
            description: "32x32 game enemy",
            category: "gameSprite",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 32,
            recommendedPalette: "retro8bit",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]

    // MARK: - App Icon Templates
    static let iconTemplates: [Template] = [
        Template(
            id: "icon_ios",
            name: "iOS App Icon",
            description: "1024x1024 iOS app icon",
            category: "icon",
            size: CGSize(width: 1024, height: 1024),
            aspectRatio: 1.0,
            pixelSize: 32,
            recommendedPalette: nil,
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "icon_small",
            name: "Small Icon",
            description: "256x256 small icon",
            category: "icon",
            size: CGSize(width: 256, height: 256),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "snes",
            hasBorder: true,
            borderColor: "#000000",
            borderWidth: 4
        )
    ]

    // MARK: - Banner Templates
    static let bannerTemplates: [Template] = [
        Template(
            id: "banner_twitter",
            name: "Twitter/X Banner",
            description: "1500x500 Twitter header",
            category: "banner",
            size: CGSize(width: 1500, height: 500),
            aspectRatio: 3.0,
            pixelSize: 50,
            recommendedPalette: "cyberpunk",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "banner_youtube",
            name: "YouTube Banner",
            description: "2560x1440 YouTube banner",
            category: "banner",
            size: CGSize(width: 2560, height: 1440),
            aspectRatio: 16/9,
            pixelSize: 80,
            recommendedPalette: "vaporwave",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        ),
        Template(
            id: "banner_discord",
            name: "Discord Banner",
            description: "960x540 Discord server banner",
            category: "banner",
            size: CGSize(width: 960, height: 540),
            aspectRatio: 16/9,
            pixelSize: 40,
            recommendedPalette: "retro8bit",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]

    // MARK: - Sticker Templates
    static let stickerTemplates: [Template] = [
        Template(
            id: "sticker_small",
            name: "Small Sticker",
            description: "256x256 small sticker",
            category: "sticker",
            size: CGSize(width: 256, height: 256),
            aspectRatio: 1.0,
            pixelSize: 12,
            recommendedPalette: "pastel",
            hasBorder: true,
            borderColor: "#FFFFFF",
            borderWidth: 6
        ),
        Template(
            id: "sticker_emoji",
            name: "Emoji Style",
            description: "512x512 emoji-sized sticker",
            category: "sticker",
            size: CGSize(width: 512, height: 512),
            aspectRatio: 1.0,
            pixelSize: 16,
            recommendedPalette: "snes",
            hasBorder: false,
            borderColor: nil,
            borderWidth: 0
        )
    ]
}

/// Preset configurations for quick access
struct EffectPreset: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let pixelSize: String
    let colorPalette: String
    let colorReduction: String
    let ditheringType: String
    let filterEffect: String
    let filterIntensity: Double

    static let presets: [EffectPreset] = [
        EffectPreset(
            id: "preset_gameboy",
            name: "GameBoy Classic",
            description: "Green monochrome GameBoy look",
            pixelSize: "16x16",
            colorPalette: "gameboy",
            colorReduction: "colors8",
            ditheringType: "floydSteinberg",
            filterEffect: "scanlines",
            filterIntensity: 0.7
        ),
        EffectPreset(
            id: "preset_nes",
            name: "NES Retro",
            description: "Classic NES game style",
            pixelSize: "12x12",
            colorPalette: "nes",
            colorReduction: "colors16",
            ditheringType: "none",
            filterEffect: "crt",
            filterIntensity: 0.8
        ),
        EffectPreset(
            id: "preset_vaporwave",
            name: "Vaporwave Aesthetic",
            description: "Pink and cyan vaporwave vibes",
            pixelSize: "22x22",
            colorPalette: "vaporwave",
            colorReduction: "colors16",
            ditheringType: "atkinson",
            filterEffect: "glitch",
            filterIntensity: 0.5
        ),
        EffectPreset(
            id: "preset_cyberpunk",
            name: "Cyberpunk Neon",
            description: "Futuristic neon colors",
            pixelSize: "16x16",
            colorPalette: "cyberpunk",
            colorReduction: "colors8",
            ditheringType: "ordered",
            filterEffect: "crt",
            filterIntensity: 1.0
        ),
        EffectPreset(
            id: "preset_pastel",
            name: "Pastel Dream",
            description: "Soft and gentle colors",
            pixelSize: "22x22",
            colorPalette: "pastel",
            colorReduction: "colors16",
            ditheringType: "floydSteinberg",
            filterEffect: "none",
            filterIntensity: 0.0
        ),
        EffectPreset(
            id: "preset_arcade",
            name: "Arcade Cabinet",
            description: "Classic arcade screen",
            pixelSize: "12x12",
            colorPalette: "retro8bit",
            colorReduction: "colors16",
            ditheringType: "none",
            filterEffect: "arcade",
            filterIntensity: 0.9
        ),
        EffectPreset(
            id: "preset_noir",
            name: "Film Noir",
            description: "Black and white classic film",
            pixelSize: "16x16",
            colorPalette: "noir",
            colorReduction: "colors8",
            ditheringType: "atkinson",
            filterEffect: "vintage",
            filterIntensity: 0.8
        ),
        EffectPreset(
            id: "preset_vhs",
            name: "VHS Tape",
            description: "90s VHS recording aesthetic",
            pixelSize: "22x22",
            colorPalette: "none",
            colorReduction: "colors32",
            ditheringType: "ordered",
            filterEffect: "vhsTape",
            filterIntensity: 0.7
        )
    ]
}

class TemplateManager: ObservableObject {
    @Published var selectedTemplate: Template?
    @Published var selectedPreset: EffectPreset?

    /// Apply template to image
    func applyTemplate(to image: UIImage, template: Template) -> UIImage? {
        var processedImage = image

        // Resize to template size
        processedImage = resizeImage(processedImage, targetSize: template.size)

        // Apply border if needed
        if template.hasBorder, let borderColor = template.borderUIColor {
            processedImage = addBorder(to: processedImage, color: borderColor, width: template.borderWidth)
        }

        return processedImage
    }

    /// Apply preset to image
    func applyPreset(to image: UIImage, preset: EffectPreset, manager: DataManager) -> UIImage? {
        var processedImage = image

        // Parse and apply settings
        // This would integrate with your existing DataManager
        // For now, we'll return the image as-is
        // You would need to call your existing pixelation, color reduction, and filter functions

        return processedImage
    }

    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func addBorder(to image: UIImage, color: UIColor, width: CGFloat) -> UIImage {
        let borderSize = CGSize(
            width: image.size.width + width * 2,
            height: image.size.height + width * 2
        )

        UIGraphicsBeginImageContextWithOptions(borderSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        // Draw border background
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: borderSize))

        // Draw image on top
        image.draw(at: CGPoint(x: width, y: width))

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    /// Get all templates
    static func getAllTemplates() -> [Template] {
        return TemplateCategory.allCases.flatMap { $0.templates }
    }

    /// Get templates by category
    static func getTemplates(for category: TemplateCategory) -> [Template] {
        return category.templates
    }

    /// Get all presets
    static func getAllPresets() -> [EffectPreset] {
        return EffectPreset.presets
    }
}
//
//  GIFCreator.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
