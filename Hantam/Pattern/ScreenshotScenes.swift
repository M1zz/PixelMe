//
//  ScreenshotScenes.swift
//  Hantam
//
//  스토어 스크린샷용 장면 — DEBUG 빌드에서만. 언어마다 같은 화면을 손 대지 않고 똑같이 찍는다.
//
//    xcrun simctl launch <기기> com.leeo.PixelMe -AppleLanguages "(ja)" \
//        -HantamScene detail -HantamDemoPhoto /path/to/photo.jpg
//
//  장면: home · maker · detail · symbols · stitch · pdf · paywall
//  paywall 은 인앱 구입 심사용 스크린샷 — -HantamPlan monthly|yearly|lifetime 으로 고른 요금제를 보인다.
//

#if DEBUG
import SwiftUI
import PDFKit

enum ScreenshotScene {
    static var current: String? { UserDefaults.standard.string(forKey: "HantamScene") }

    static var demoPhoto: UIImage? {
        guard let path = UserDefaults.standard.string(forKey: "HantamDemoPhoto") else { return nil }
        return UIImage(contentsOfFile: path)
    }

    /// 심사용 결제 화면에 보일 가격 (App Store Connect 에 넣을 미국 가격과 같게).
    static func reviewPrice(_ key: String) -> String? {
        guard current == "paywall" else { return nil }
        return ["monthly": "$3.99", "yearly": "$24.99",
                "lifetime": "$44.99", "yearlyMonthly": "$2.08"][key]
    }

    static var reviewPlan: SubscriptionPlan {
        switch UserDefaults.standard.string(forKey: "HantamPlan") {
        case "monthly": return .monthly
        case "yearly": return .yearly
        default: return .lifetime
        }
    }

    /// 데모 도안 제목 — 앱 문구가 아니라 사용자가 붙인 이름이므로 번역 카탈로그에 넣지 않는다.
    static func title(_ kind: String) -> String {
        let lang = Locale.preferredLanguages.first ?? "en"
        let table: [String: [String: String]] = [
            "ko": ["bead": "우리 집 비글", "stitch": "비글 액자", "heart": "하트 키링"],
            "ja": ["bead": "うちのビーグル", "stitch": "ビーグルの額", "heart": "ハートのキーホルダー"],
            "en": ["bead": "My beagle", "stitch": "Beagle frame", "heart": "Heart keychain"],
            "en-GB": ["bead": "My beagle", "stitch": "Beagle frame", "heart": "Heart keyring"],
            "zh-Hans": ["bead": "我家的比格犬", "stitch": "比格犬画框", "heart": "爱心钥匙扣"],
            "zh-Hant": ["bead": "我家的米格魯", "stitch": "米格魯相框", "heart": "愛心鑰匙圈"],
            "ru": ["bead": "Мой бигль", "stitch": "Бигль в рамке", "heart": "Брелок-сердце"],
            "es": ["bead": "Mi beagle", "stitch": "Cuadro del beagle", "heart": "Llavero de corazón"],
            "de": ["bead": "Mein Beagle", "stitch": "Beagle-Bild", "heart": "Herz-Anhänger"],
            "fr": ["bead": "Mon beagle", "stitch": "Cadre beagle", "heart": "Porte-clés cœur"],
            "it": ["bead": "Il mio beagle", "stitch": "Quadretto beagle", "heart": "Portachiavi cuore"],
            "pt-BR": ["bead": "Meu beagle", "stitch": "Quadro do beagle", "heart": "Chaveiro de coração"],
            "th": ["bead": "บีเกิลของฉัน", "stitch": "กรอบรูปบีเกิล", "heart": "พวงกุญแจหัวใจ"],
            "vi": ["bead": "Chú beagle nhà tôi", "stitch": "Khung tranh beagle", "heart": "Móc khóa trái tim"],
            "cs": ["bead": "Můj bígl", "stitch": "Bígl v rámečku", "heart": "Přívěsek srdce"],
            "da": ["bead": "Min beagle", "stitch": "Beagle i ramme", "heart": "Hjerte-nøglering"],
            "el": ["bead": "Το μπιγκλ μου", "stitch": "Κάδρο με μπιγκλ", "heart": "Μπρελόκ καρδιά"],
            "fi": ["bead": "Meidän beagle", "stitch": "Beagle-taulu", "heart": "Sydänavaimenperä"],
            "id": ["bead": "Beagle-ku", "stitch": "Bingkai beagle", "heart": "Gantungan kunci hati"],
            "nb": ["bead": "Beaglen min", "stitch": "Beagle i ramme", "heart": "Hjerte-nøkkelring"],
            "nl": ["bead": "Onze beagle", "stitch": "Beagle-lijstje", "heart": "Hartjessleutelhanger"],
            "pl": ["bead": "Mój beagle", "stitch": "Beagle w ramce", "heart": "Brelok serce"],
            "sv": ["bead": "Min beagle", "stitch": "Beagle i ram", "heart": "Hjärtnyckelring"],
            "tr": ["bead": "Benim beagle'ım", "stitch": "Beagle çerçevesi", "heart": "Kalpli anahtarlık"],
        ]
        // 가장 긴 접두사부터 맞춘다 — en-GB 가 en 보다 먼저.
        let key = table.keys.sorted { $0.count > $1.count }.first { lang.hasPrefix($0) } ?? "en"
        return table[key]?[kind] ?? kind
    }

    static func pattern(_ material: PatternMaterial, side: Int, colors: Int, title: String, from image: UIImage) -> BeadPattern? {
        var s = PatternSettings()
        s.material = material
        s.longestSide = side
        s.maxColors = colors
        var p = PatternEngine.makePattern(from: image, settings: s, title: title)
        p?.createdAt = Date()
        return p
    }

    static func heart() -> BeadPattern {
        let rows = BeadHeartMark.rows
        let w = rows[0].count + 2, h = rows.count + 2
        var cells = [Int](repeating: -1, count: w * h)
        for (y, row) in rows.enumerated() {
            for (x, ch) in row.enumerated() where ch == "#" {
                cells[(y + 1) * w + x + 1] = BeadHeartMark.isAccent(y, x) ? 1 : 0
            }
        }
        let red = PatternColor.perler.first { $0.name == "Red" } ?? PatternColor.perler[0]
        let yellow = PatternColor.perler.first { $0.name == "Yellow" } ?? PatternColor.perler[1]
        return BeadPattern(title: title("heart"), material: .perler, width: w, height: h, cells: cells, colors: [red, yellow])
    }
}

/// 장면을 띄운다. 데모 도안은 사진 한 장에서 만들어 내 도안에 넣는다.
struct ScreenshotSceneRoot: View {
    let scene: String
    @EnvironmentObject var manager: DataManager
    @State private var ready: (bead: BeadPattern, stitch: BeadPattern)?

    var body: some View {
        Group {
            if scene == "paywall" {
                // 결제 화면은 데모 도안이 필요 없다 — 바로 띄운다.
                PaywallView(isProUser: .constant(false), reason: .patternPDF, initialPlan: ScreenshotScene.reviewPlan)
            } else if let ready {
                switch scene {
                case "maker":
                    PatternMakerView(startWithPicker: false, initialImage: ScreenshotScene.demoPhoto)
                case "detail":
                    PatternDetailView(pattern: ready.bead)
                case "symbols":
                    PatternDetailView(pattern: ready.bead, initialStyle: .symbol, initialZoom: 2.2)
                case "stitch":
                    PatternDetailView(pattern: ready.stitch)
                case "pdf":
                    PDFSceneView(pattern: ready.bead)
                default:
                    CreatorContentView().environmentObject(manager)
                }
            } else {
                Color.hantamBackground.ignoresSafeArea()
            }
        }
        .task { if scene != "paywall" { await prepare() } }
    }

    private func prepare() async {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        guard let photo = ScreenshotScene.demoPhoto else { return }
        let subject: UIImage = await withCheckedContinuation { cont in
            BackgroundRemovalManager.removeBackgroundSmart(from: photo) { cont.resume(returning: $0 ?? photo) }
        }
        let made: (BeadPattern, BeadPattern)? = await Task.detached {
            guard let b = ScreenshotScene.pattern(.perler, side: 58, colors: 18, title: ScreenshotScene.title("bead"), from: subject),
                  let s = ScreenshotScene.pattern(.dmc, side: 80, colors: 24, title: ScreenshotScene.title("stitch"), from: photo)
            else { return nil }
            return (b, s)
        }.value
        guard let made else { return }
        let store = PatternStore.shared
        for p in store.patterns { store.delete(p) }
        store.save(ScreenshotScene.heart())
        store.save(made.1)
        store.save(made.0)
        ready = (made.0, made.1)
    }
}

/// 인쇄용 PDF 한 쪽(보드 한 장)을 보여 주는 장면.
private struct PDFSceneView: View {
    let pattern: BeadPattern

    var body: some View {
        NavigationStack {
            PDFKitView(data: PatternRenderer.pdfData(for: pattern))
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(pattern.title + ".pdf")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct PDFKitView: UIViewRepresentable {
    let data: Data
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.document = PDFDocument(data: data)
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.backgroundColor = UIColor.secondarySystemBackground
        if let page = v.document?.page(at: 1) { v.go(to: page) }
        return v
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
#endif
