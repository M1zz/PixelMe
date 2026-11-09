//
//  HantamApp.swift
//  Hantam
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI
import LeeoKit

@main
struct HantamApp: App {
    @StateObject private var manager: DataManager = DataManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // 실행 기록 + 익명 사용 통계·크래시 진단(FeedbackHub)을 한 번에 켠다.
        LeeoKit.bootstrap(HantamSpec.self)
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .environmentObject(manager)
                .leeoSatisfactionCheck(HantamSpec.self)
                // 개발자가 보낸 의견에 답장하면, 앱이 앞으로 올 때 답장을 시트로 보여 준다 (LeeoKit).
                .leeoFeedbackReplyNotice(HantamSpec.self)
                // 유료 다운로드 시절 구매자에게 고마움 한 번, 구독자에게 구독 졸업 제안.
                .modifier(PlanMoments())
                .onAppear {
                    ReviewManager.shared.trackAppLaunch()
                }
                .onOpenURL { url in
                    handleAsepriteFile(url)
                }
                // 아이폰 듀오: 접힘을 재서 아래로 흘린다. 시트 · 알림창도 접힌 선을 비킨다 (LeeoKit Fold).
                .foldAware()
                // Spotlight 에 싣는 내 도안을 지금 것에 맞춘다. 열 때 한 번, 뒤로 보낼 때마다.
                .task { await PatternLibrary.reindex() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background { Task { await PatternLibrary.reindex() } }
                }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        if let scene = ScreenshotScene.current {
            ScreenshotSceneRoot(scene: scene)
        } else {
            CreatorContentView()
        }
        #else
        CreatorContentView()
        #endif
    }

    private func handleAsepriteFile(_ url: URL) {
        let ext = url.pathExtension.lowercased()
        guard ext == "aseprite" || ext == "ase" else { return }

        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let (_, _, frames) = try AsepriteManager.importFile(from: url)
            // DataManager에 가져온 데이터를 저장하고 에디터를 열도록 알림
            manager.importedAsepriteFrames = frames
            manager.shouldOpenPixelEditor = true
        } catch {
            presentAlert(title: "Aseprite 가져오기 실패", message: error.localizedDescription)
        }
    }
}

// MARK: - 요금제가 말을 거는 순간

/// 앱을 열 때 한 번씩 보는 요금제 안내.
///  - 앱을 돈 내고 받았던 사람: 이제 무료가 됐고 Pro 는 평생 당신 것이라는 고마움 한 번.
///  - 구독 중인 사람: 6개월째 · 갱신 7일 전에 구독 졸업 평생가 한 번씩(LeeoGraduation). 산 뒤 해지 화면으로 안내.
private struct PlanMoments: ViewModifier {
    @ObservedObject private var subscription = SubscriptionManager.shared
    @State private var showsThanks = false
    @State private var showsGraduation = false

    func body(content: Content) -> some View {
        content
            .task {
                if subscription.owesPaidDownloadThanks {
                    showsThanks = true
                } else if await subscription.takeGraduationOffer() {
                    showsGraduation = true
                }
            }
            // 그랜드파더링 확인은 앱이 뜬 뒤에 끝나므로 바뀌는 때도 본다.
            .onChange(of: subscription.owesPaidDownloadThanks) { _, owes in
                if owes { showsThanks = true }
            }
            .alert("Thank you for buying Hantam", isPresented: $showsThanks) {
                Button("OK", role: .cancel) { subscription.markPaidDownloadThanked() }
            } message: {
                Text("Hantam is now free to download. Because you bought it, Pro is yours for life, printable PDF patterns included.")
            }
            .sheet(isPresented: $showsGraduation) {
                LeeoGraduationOfferView(
                    graduate: subscription.product(AppConfig.proGraduateProductID),
                    onPurchased: { await subscription.checkSubscriptionStatus() })
            }
    }
}

// MARK: - Present an alert from anywhere in the app
func presentAlert(title: String, message: String, primaryAction: UIAlertAction = .ok, secondaryAction: UIAlertAction? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(primaryAction)
    if let secondary = secondaryAction { alert.addAction(secondary) }
    rootController?.present(alert, animated: true, completion: nil)
}

var rootController: UIViewController? {
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    var root = scene?.windows.first?.rootViewController
    if let presenter = root?.presentedViewController { root = presenter }
    return root
}

extension UIAlertAction {
    static var ok: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
}
