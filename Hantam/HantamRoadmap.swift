//
//  HantamRoadmap.swift
//  Hantam
//
//  **앞으로 만들 것**의 원본. 설정 ▸ Support ▸ 앞으로 만들 기능(`LeeoRoadmapView`)이 이 목록을 그대로 보여 준다.
//
//  ⚠️ 개발하다 "이건 다음에" 가 생기면 **여기에 한 줄을 더한다.** 코드의 TODO 주석으로만 남기지 않는다.
//     - 새 항목: `.planned`. 손대기 시작하면 `.building`. 내보내면 `.shipped("2.1.0")`.
//     - id 는 한 번 정하면 바꾸지 않는다(문구는 바꿔도 된다). 같은 피처는 다른 앱과 같은 id 를 쓴다.
//     - 문구는 사용자 말로 쓴다(내부 이름 · 기술 용어 금지). 이 앱은 영어 키 + 한국어 번역이다
//       (`Localizable.xcstrings`, sourceLanguage en) — 새 키를 넣으면 ko 를 함께 채운다.
//     - 사용자에게 보일 만한 것만 적는다. 리팩터링 · 시험 · 빌드 설정은 `.sprintcommander/tasks.json` 의 몫이다.
//

import SwiftUI
import LeeoKit

extension HantamSpec {
    static var roadmap: [LeeoRoadmapItem] {[
        // MARK: 다음에 만들어요
        .init(id: "pattern.owned-colors", status: .planned,
              title: NSLocalizedString("Use only colors I own", comment: "Roadmap item: limit pattern to owned colors"),
              detail: NSLocalizedString("Check the beads or thread you have, and patterns use only those colors.", comment: "Roadmap item detail: limit pattern to owned colors")),
        .init(id: "pattern.cleanup", status: .planned,
              title: NSLocalizedString("Tidy up stray beads", comment: "Roadmap item: remove single stray beads"),
              detail: NSLocalizedString("Lonely single beads of an odd color are smoothed out in one tap.", comment: "Roadmap item detail: remove single stray beads")),
        .init(id: "pattern.mini-beads", status: .planned,
              title: NSLocalizedString("Mini beads and more brands", comment: "Roadmap item: more bead brands"),
              detail: NSLocalizedString("Patterns for 2.6 mm mini beads and more bead brands.", comment: "Roadmap item detail: more bead brands")),
        .init(id: "a11y.voiceover", status: .planned,
              title: NSLocalizedString("Better VoiceOver support", comment: "Roadmap item: better VoiceOver support"),
              detail: NSLocalizedString("VoiceOver reads every button and tool, in the right order.", comment: "Roadmap item detail: better VoiceOver support")),
        .init(id: "a11y.largetext", status: .planned,
              title: NSLocalizedString("Layouts that fit larger text", comment: "Roadmap item: Dynamic Type layouts"),
              detail: NSLocalizedString("Bigger text never gets cut off — the screen rearranges itself neatly.", comment: "Roadmap item detail: Dynamic Type layouts")),
        .init(id: "a11y.contrast", status: .planned,
              title: NSLocalizedString("Easier-to-see colors and contrast", comment: "Roadmap item: contrast and color"),
              detail: NSLocalizedString("Everything stays readable with Increase Contrast on or if colors are hard to tell apart.", comment: "Roadmap item detail: contrast and color")),
        .init(id: "a11y.motion", status: .planned,
              title: NSLocalizedString("Reduce Motion", comment: "Roadmap item: reduce motion"),
              detail: NSLocalizedString("With Reduce Motion on, animations become calmer.", comment: "Roadmap item detail: reduce motion")),
        .init(id: "lang.more", status: .planned,
              title: NSLocalizedString("More languages", comment: "Roadmap item: more languages"),
              detail: NSLocalizedString("Use the app in even more languages.", comment: "Roadmap item detail: more languages")),
        .init(id: "whatsnew", status: .planned,
              title: NSLocalizedString("What’s New", comment: "Roadmap item: what's new"),
              detail: NSLocalizedString("The first time you open the app after an update, you’ll see what’s new.", comment: "Roadmap item detail: what's new")),
        .init(id: "tips", status: .planned,
              title: NSLocalizedString("Helpful tips", comment: "Roadmap item: tips"),
              detail: NSLocalizedString("Handy features are pointed out gently, right when they’re useful.", comment: "Roadmap item detail: tips")),
        .init(id: "gift", status: .planned,
              title: NSLocalizedString("Gift Pro", comment: "Roadmap item: gift Pro"),
              detail: NSLocalizedString("You pay, and the person you choose gets Pro.", comment: "Roadmap item detail: gift Pro")),
        .init(id: "haptics", status: .planned,
              title: NSLocalizedString("Haptic feedback", comment: "Roadmap item: haptics"),
              detail: NSLocalizedString("Feel a light tap when you draw or finish something.", comment: "Roadmap item detail: haptics")),
        .init(id: "widgets", status: .planned,
              title: NSLocalizedString("Home Screen widgets", comment: "Roadmap item: home screen widgets"),
              detail: NSLocalizedString("See your pixel art on the Home Screen without opening the app.", comment: "Roadmap item detail: home screen widgets")),
        .init(id: "shortcuts", status: .planned,
              title: NSLocalizedString("Siri and Shortcuts", comment: "Roadmap item: Siri and Shortcuts"),
              detail: NSLocalizedString("Turn a photo into pixel art straight from Siri or the Shortcuts app.", comment: "Roadmap item detail: Siri and Shortcuts")),
        .init(id: "sync.icloud", status: .planned,
              title: NSLocalizedString("Sync across devices", comment: "Roadmap item: iCloud sync"),
              detail: NSLocalizedString("Your pixel art follows you to a new iPhone through iCloud.", comment: "Roadmap item detail: iCloud sync")),
        .init(id: "backup", status: .planned,
              title: NSLocalizedString("Backup and export", comment: "Roadmap item: backup and export"),
              detail: NSLocalizedString("Save your work to a file and bring it back anytime.", comment: "Roadmap item detail: backup and export")),
        .init(id: "lock.faceid", status: .planned,
              title: NSLocalizedString("Face ID lock", comment: "Roadmap item: Face ID lock"),
              detail: NSLocalizedString("Lock the app with Face ID to keep your work private.", comment: "Roadmap item detail: Face ID lock")),
        .init(id: "notifications", status: .planned,
              title: NSLocalizedString("Done notifications", comment: "Roadmap item: notifications"),
              detail: NSLocalizedString("Get a notification when a long conversion finishes.", comment: "Roadmap item detail: notifications")),
        .init(id: "fold", status: .planned,
              title: NSLocalizedString("Foldable iPhone layout", comment: "Roadmap item: foldable iPhone layout"),
              detail: NSLocalizedString("Split the wide screen of a foldable iPhone into two sides.", comment: "Roadmap item detail: foldable iPhone layout")),
        .init(id: "data.delete", status: .planned,
              title: NSLocalizedString("Delete all my data", comment: "Roadmap item: delete all data"),
              detail: NSLocalizedString("Erase all your saved work and settings right in the app.", comment: "Roadmap item detail: delete all data")),
    ]}
}

// MARK: - 화면

/// 설정 ▸ 앞으로 만들 기능. "이런 기능이 있으면 좋겠어요" 는 기능 제안으로 시작하는 피드백 창을 연다.
struct RoadmapScreen: View {
    @State private var showFeedback = false

    var body: some View {
        LeeoRoadmapView<HantamSpec>(onSuggest: { showFeedback = true })
            .sheet(isPresented: $showFeedback) {
                NavigationStack {
                    LeeoFeedbackView<HantamSpec>(initialType: .feature)
                }
            }
    }
}
