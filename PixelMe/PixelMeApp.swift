//
//  PixelMeApp.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

@main
struct PixelMeApp: App {
    @StateObject private var manager: DataManager = DataManager()
    var body: some Scene {
        WindowGroup {
            CreatorContentView()
                .environmentObject(manager)
                .onAppear {
                    ReviewManager.shared.trackAppLaunch()
                }
                .onOpenURL { url in
                    handleAsepriteFile(url)
                }
        }
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
