//
//  FilterPackManager.swift
//  PixelMe
//
//  시즌 필터 팩 관리: 카탈로그, 구매, 접근 제어
//

import StoreKit
import SwiftUI

@MainActor
class FilterPackManager: ObservableObject {

    // MARK: - Singleton

    static let shared = FilterPackManager()

    // MARK: - Published Properties

    /// 사용 가능한 전체 팩 카탈로그
    @Published private(set) var allPacks: [FilterPack] = []
    /// 구매된 팩 ID 목록
    @Published private(set) var purchasedPackIDs: Set<String> = []
    /// StoreKit 상품 (productID → Product)
    @Published private(set) var storeProducts: [String: Product] = [:]
    /// 로딩 상태
    @Published private(set) var isLoading: Bool = false
    /// 에러 메시지
    @Published var errorMessage: String?

    // MARK: - Private

    private let purchasedKey = "FilterPackManager.purchasedPacks"
    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Init

    private init() {
        loadCatalog()
        loadPurchasedPacks()
        updateListenerTask = listenForTransactions()
        Task {
            await loadStoreProducts()
            await checkPurchasedPacks()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Catalog

    /// 내장 카탈로그 로드 (서버 없이 앱 번들에서 관리)
    private func loadCatalog() {
        allPacks = Self.builtInPacks
    }

    /// 현재 시즌에 표시 가능한 팩들
    var availablePacks: [FilterPack] {
        allPacks.filter { $0.isCurrentlyAvailable }
    }

    /// 특정 팩이 구매되었거나 Pro 사용자인지 확인
    func hasAccess(to pack: FilterPack) -> Bool {
        if SubscriptionManager.shared.isProUser { return true }
        return purchasedPackIDs.contains(pack.id)
    }

    /// 특정 PackFilter에 접근 가능한지 확인
    func hasAccessToFilter(_ filterId: String) -> Bool {
        if SubscriptionManager.shared.isProUser { return true }
        for pack in allPacks {
            if pack.filters.contains(where: { $0.id == filterId }) {
                return purchasedPackIDs.contains(pack.id)
            }
        }
        return false
    }

    // MARK: - StoreKit 2

    /// App Store에서 필터 팩 상품 로드
    func loadStoreProducts() async {
        isLoading = true
        let productIDs = allPacks.map { $0.productID }
        do {
            let products = try await Product.products(for: productIDs)
            var map: [String: Product] = [:]
            for product in products {
                map[product.id] = product
            }
            storeProducts = map
            print("[FilterPackManager] \(products.count)개 상품 로드 완료")
        } catch {
            print("[FilterPackManager] 상품 로드 실패: \(error)")
            errorMessage = "Failed to load filter pack products."
        }
        isLoading = false
    }

    /// 팩 구매
    func purchasePack(_ pack: FilterPack) async -> Bool {
        guard let product = storeProducts[pack.productID] else {
            errorMessage = "Product not found. Please try again."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedPackIDs.insert(pack.id)
                savePurchasedPacks()
                await transaction.finish()
                print("[FilterPackManager] \(pack.name) 구매 성공")
                isLoading = false
                return true
            case .userCancelled:
                isLoading = false
                return false
            case .pending:
                errorMessage = "Purchase pending approval."
                isLoading = false
                return false
            @unknown default:
                errorMessage = "An unexpected error occurred."
                isLoading = false
                return false
            }
        } catch {
            print("[FilterPackManager] 구매 실패: \(error)")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    /// 구매 내역에서 팩 확인
    func checkPurchasedPacks() async {
        let packProductIDs = Set(allPacks.map { $0.productID })
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if packProductIDs.contains(transaction.productID) {
                    if let pack = allPacks.first(where: { $0.productID == transaction.productID }) {
                        purchasedPackIDs.insert(pack.id)
                    }
                }
            }
        }
        savePurchasedPacks()
    }

    /// 구매 복원
    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await checkPurchasedPacks()
            if purchasedPackIDs.isEmpty {
                errorMessage = "No previous filter pack purchases found."
            }
        } catch {
            errorMessage = "Failed to restore: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Applying Filters

    /// PackFilter를 이미지에 적용
    nonisolated static func applyPackFilter(_ packFilter: PackFilter, to image: UIImage) -> UIImage? {
        var result = image

        // 1) 팔레트 적용
        if let palette = packFilter.colorPaletteType, palette != .none {
            result = applyPaletteMapping(result, palette: palette)
        }

        // 2) 색상 보정 (brightness/contrast/saturation)
        if packFilter.brightnessAdjust != 0 || packFilter.contrastAdjust != 1.0 || packFilter.saturationAdjust != 1.0 {
            if let adjusted = applyColorAdjustments(
                to: result,
                brightness: packFilter.brightnessAdjust,
                contrast: packFilter.contrastAdjust,
                saturation: packFilter.saturationAdjust
            ) {
                result = adjusted
            }
        }

        // 3) 필터 효과 적용
        if let filterType = packFilter.filterEffectType, filterType != .none {
            if let filtered = FilterEffectsEngine.applyFilter(
                to: result,
                type: filterType,
                intensity: packFilter.filterIntensity
            ) {
                result = filtered
            }
        }

        return result
    }

    /// 팔레트 매핑 적용
    private nonisolated static func applyPaletteMapping(_ image: UIImage, palette: ColorPaletteType) -> UIImage {
        guard !palette.colors.isEmpty else { return image }
        guard let cgImage = image.cgImage else { return image }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        guard let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return image }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return image }

        let pixels = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        let paletteColors = palette.colors

        for i in 0..<(width * height) {
            let offset = i * bytesPerPixel
            let r = CGFloat(pixels[offset]) / 255.0
            let g = CGFloat(pixels[offset + 1]) / 255.0
            let b = CGFloat(pixels[offset + 2]) / 255.0

            let pixelColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            let closest = pixelColor.closestColor(in: paletteColors)

            var cr: CGFloat = 0, cg: CGFloat = 0, cb: CGFloat = 0, ca: CGFloat = 0
            closest.getRed(&cr, green: &cg, blue: &cb, alpha: &ca)

            pixels[offset] = UInt8(cr * 255)
            pixels[offset + 1] = UInt8(cg * 255)
            pixels[offset + 2] = UInt8(cb * 255)
        }

        guard let newCGImage = context.makeImage() else { return image }
        return UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// CIFilter 기반 색상 보정
    private nonisolated static func applyColorAdjustments(
        to image: UIImage,
        brightness: CGFloat,
        contrast: CGFloat,
        saturation: CGFloat
    ) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()

        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)
        filter.setValue(saturation, forKey: kCIInputSaturationKey)

        guard let output = filter.outputImage,
              let result = context.createCGImage(output, from: ciImage.extent) else { return nil }

        return UIImage(cgImage: result, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Persistence

    private func savePurchasedPacks() {
        UserDefaults.standard.set(Array(purchasedPackIDs), forKey: purchasedKey)
    }

    private func loadPurchasedPacks() {
        if let saved = UserDefaults.standard.stringArray(forKey: purchasedKey) {
            purchasedPackIDs = Set(saved)
        }
    }

    // MARK: - Transaction

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let safe): return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await self.checkPurchasedPacks()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Price Helpers

    func displayPrice(for pack: FilterPack) -> String {
        storeProducts[pack.productID]?.displayPrice ?? pack.price
    }
}

// MARK: - Built-in Pack Catalog

extension FilterPackManager {

    /// 내장 필터 팩 카탈로그
    static let builtInPacks: [FilterPack] = [
        // ── 90년대 아케이드 팩 ──
        FilterPack(
            id: "pack_90s_arcade",
            name: "90s Arcade",
            description: "Classic arcade cabinet vibes with CRT glow, scanlines, and retro palettes",
            productID: "com.pixelme.filterpack.arcade90s",
            price: "₩1,900",
            iconName: "gamecontroller.fill",
            accentColorHex: "#FF4500",
            season: .arcade,
            filters: [
                PackFilter(
                    id: "arcade_neon_glow",
                    name: "Neon Glow",
                    description: "Bright neon arcade cabinet glow",
                    baseFilter: "CRT Monitor",
                    basePalette: "Cyberpunk",
                    filterIntensity: 0.7,
                    brightnessAdjust: 0.05,
                    contrastAdjust: 1.2,
                    saturationAdjust: 1.4
                ),
                PackFilter(
                    id: "arcade_coin_op",
                    name: "Coin-Op",
                    description: "Classic coin-operated machine look",
                    baseFilter: "Arcade Screen",
                    basePalette: "NES",
                    filterIntensity: 0.8,
                    brightnessAdjust: 0.0,
                    contrastAdjust: 1.3,
                    saturationAdjust: 1.1
                ),
                PackFilter(
                    id: "arcade_pixel_blast",
                    name: "Pixel Blast",
                    description: "High-contrast pixel explosion",
                    baseFilter: "Scanlines",
                    basePalette: "8-Bit Retro",
                    filterIntensity: 0.6,
                    brightnessAdjust: 0.03,
                    contrastAdjust: 1.4,
                    saturationAdjust: 1.2
                ),
                PackFilter(
                    id: "arcade_game_over",
                    name: "Game Over",
                    description: "Dark retro game over screen mood",
                    baseFilter: "CRT Monitor",
                    basePalette: "Film Noir",
                    filterIntensity: 0.9,
                    brightnessAdjust: -0.05,
                    contrastAdjust: 1.5,
                    saturationAdjust: 0.6
                ),
                PackFilter(
                    id: "arcade_vaporwave_cabinet",
                    name: "Vapor Cabinet",
                    description: "Vaporwave meets arcade aesthetics",
                    baseFilter: "VHS Tape",
                    basePalette: "Vaporwave",
                    filterIntensity: 0.7,
                    brightnessAdjust: 0.02,
                    contrastAdjust: 1.1,
                    saturationAdjust: 1.3
                ),
                PackFilter(
                    id: "arcade_boss_fight",
                    name: "Boss Fight",
                    description: "Intense boss battle screen with high contrast",
                    baseFilter: "Arcade Screen",
                    basePalette: "SNES",
                    filterIntensity: 0.85,
                    brightnessAdjust: -0.02,
                    contrastAdjust: 1.5,
                    saturationAdjust: 1.3
                )
            ],
            customPalettes: [
                PackPalette(
                    id: "pal_arcade_neon",
                    name: "Arcade Neon",
                    colors: ["#0D0D0D", "#FF0040", "#00FF88", "#FFFF00", "#FF00FF", "#00CCFF", "#FF8800", "#FFFFFF"]
                ),
                PackPalette(
                    id: "pal_arcade_crt",
                    name: "CRT Phosphor",
                    colors: ["#000000", "#003300", "#006600", "#009900", "#00CC00", "#00FF00", "#66FF66", "#CCFFCC"]
                )
            ],
            availableFrom: nil,
            availableUntil: nil
        ),

        // ── 스프링 블룸 팩 ──
        FilterPack(
            id: "pack_spring_bloom",
            name: "Spring Bloom",
            description: "Soft pastel tones and warm light for a fresh spring feeling",
            productID: "com.pixelme.filterpack.spring",
            price: "₩1,900",
            iconName: "leaf.fill",
            accentColorHex: "#FF9EC6",
            season: .spring,
            filters: [
                PackFilter(
                    id: "spring_cherry",
                    name: "Cherry Blossom",
                    description: "Soft pink cherry blossom tones",
                    baseFilter: "Vintage Game",
                    basePalette: "Pastel",
                    filterIntensity: 0.4,
                    brightnessAdjust: 0.06,
                    contrastAdjust: 0.95,
                    saturationAdjust: 1.1
                ),
                PackFilter(
                    id: "spring_morning_dew",
                    name: "Morning Dew",
                    description: "Fresh morning light with cool greens",
                    baseFilter: "None",
                    basePalette: "Pastel",
                    filterIntensity: 0.0,
                    brightnessAdjust: 0.08,
                    contrastAdjust: 0.9,
                    saturationAdjust: 0.85
                ),
                PackFilter(
                    id: "spring_garden",
                    name: "Pixel Garden",
                    description: "Vibrant garden colors in pixel form",
                    baseFilter: "None",
                    basePalette: "SNES",
                    filterIntensity: 0.0,
                    brightnessAdjust: 0.04,
                    contrastAdjust: 1.05,
                    saturationAdjust: 1.2
                ),
                PackFilter(
                    id: "spring_sunset",
                    name: "Spring Sunset",
                    description: "Warm golden hour spring evening",
                    baseFilter: "Vintage Game",
                    basePalette: "Original",
                    filterIntensity: 0.5,
                    brightnessAdjust: 0.03,
                    contrastAdjust: 1.1,
                    saturationAdjust: 1.15
                )
            ],
            customPalettes: [
                PackPalette(
                    id: "pal_cherry_blossom",
                    name: "Cherry Blossom",
                    colors: ["#FFFFFF", "#FFE4EC", "#FFB7D0", "#FF87AC", "#E85D8C", "#C4386C", "#6B1D3F", "#2D0A1A"]
                )
            ],
            availableFrom: nil,
            availableUntil: nil
        ),

        // ── 사이버 나이트 팩 ──
        FilterPack(
            id: "pack_cyber_night",
            name: "Cyber Night",
            description: "Neon-lit dark cityscapes with glitch and cyberpunk aesthetics",
            productID: "com.pixelme.filterpack.cybernight",
            price: "₩2,900",
            iconName: "moon.stars.fill",
            accentColorHex: "#00FFFF",
            season: .special,
            filters: [
                PackFilter(
                    id: "cyber_neon_rain",
                    name: "Neon Rain",
                    description: "Cyberpunk neon rain in the dark city",
                    baseFilter: "Glitch",
                    basePalette: "Cyberpunk",
                    filterIntensity: 0.5,
                    brightnessAdjust: -0.03,
                    contrastAdjust: 1.3,
                    saturationAdjust: 1.5
                ),
                PackFilter(
                    id: "cyber_hologram",
                    name: "Hologram",
                    description: "Holographic glitch display effect",
                    baseFilter: "Glitch",
                    basePalette: "Vaporwave",
                    filterIntensity: 0.6,
                    brightnessAdjust: 0.02,
                    contrastAdjust: 1.2,
                    saturationAdjust: 1.4
                ),
                PackFilter(
                    id: "cyber_matrix",
                    name: "Matrix",
                    description: "The digital world inside the machine",
                    baseFilter: "CRT Monitor",
                    basePalette: "Original",
                    filterIntensity: 0.8,
                    brightnessAdjust: -0.05,
                    contrastAdjust: 1.4,
                    saturationAdjust: 0.5
                ),
                PackFilter(
                    id: "cyber_synthwave",
                    name: "Synthwave",
                    description: "Retro-futuristic synthwave sunset",
                    baseFilter: "VHS Tape",
                    basePalette: "Vaporwave",
                    filterIntensity: 0.6,
                    brightnessAdjust: 0.0,
                    contrastAdjust: 1.15,
                    saturationAdjust: 1.3
                ),
                PackFilter(
                    id: "cyber_blacklight",
                    name: "Blacklight",
                    description: "UV blacklight party effect",
                    baseFilter: "CRT Monitor",
                    basePalette: "Cyberpunk",
                    filterIntensity: 0.7,
                    brightnessAdjust: -0.08,
                    contrastAdjust: 1.6,
                    saturationAdjust: 1.8
                ),
                PackFilter(
                    id: "cyber_data_corrupt",
                    name: "Data Corrupt",
                    description: "Heavy digital data corruption",
                    baseFilter: "Glitch",
                    basePalette: "Cyberpunk",
                    filterIntensity: 0.9,
                    brightnessAdjust: -0.02,
                    contrastAdjust: 1.3,
                    saturationAdjust: 1.2
                )
            ],
            customPalettes: [
                PackPalette(
                    id: "pal_neon_city",
                    name: "Neon City",
                    colors: ["#0A0A1A", "#1A0033", "#FF00FF", "#00FFFF", "#FF0066", "#6600FF", "#00FF66", "#FFFF00"]
                ),
                PackPalette(
                    id: "pal_synthwave",
                    name: "Synthwave",
                    colors: ["#0D0221", "#261447", "#6B1D6B", "#C94277", "#F56FAD", "#FFAFD0", "#1AEBFF", "#FFFFFF"]
                )
            ],
            availableFrom: nil,
            availableUntil: nil
        )
    ]
}
