//
//  PatternIntents.swift
//  Hantam
//
//  "한땀으로 도안 만들어줘" — 도안 만들기를 바로 연다.
//  단축어에서 사진을 넘기면(사진 공유 → 단축어) 그 사진으로 바로 도안을 만든다.
//

import AppIntents
import UIKit

@MainActor @Observable
final class PatternRouter {
    struct Photo: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    static let shared = PatternRouter()
    /// 늘어날 때마다 도안 만들기를 연다(사진은 그 안에서 고른다).
    var makerRequest = 0
    /// 단축어가 넘긴 사진. 그 사진으로 도안 만들기를 연다.
    var photo: Photo?
}

struct MakePatternIntent: AppIntent {
    static let title = LocalizedStringResource("Make a Pattern", comment: "Siri: turn a photo into a bead or cross-stitch pattern")
    static let description = IntentDescription(
        LocalizedStringResource("Turns a photo into a bead or cross-stitch pattern. Opens the photo picker if no photo is given.", comment: "Siri: make pattern description")
    )
    static let openAppWhenRun = true

    /// 그림이 아닌 파일은 읽지 못해 걸러진다.
    @Parameter(title: LocalizedStringResource("Photo", comment: "Siri: photo parameter"))
    var photo: IntentFile?

    @MainActor
    func perform() async throws -> some IntentResult {
        if let data = photo?.data, let image = UIImage(data: data) {
            PatternRouter.shared.photo = .init(image: image)
        } else {
            PatternRouter.shared.makerRequest &+= 1
        }
        return .result()
    }
}

struct HantamShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MakePatternIntent(),
            phrases: ["Make a pattern with \(.applicationName)", "Turn a photo into a pattern with \(.applicationName)"],
            shortTitle: "Make a Pattern",
            systemImageName: "square.grid.3x3"
        )
    }
}
