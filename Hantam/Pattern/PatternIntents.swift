//
//  PatternIntents.swift
//  Hantam
//
//  "한땀으로 도안 만들어줘" — 도안 만들기를 바로 연다.
//  단축어에서 사진을 넘기면(사진 공유 → 단축어) 그 사진으로 바로 도안을 만든다.
//  저장한 내 도안은 Spotlight · Siri 가 이름으로 찾는다. 누르면 그 도안이 열린다.
//  색인(IndexedEntity)은 iOS 18 부터라 그 부분만 나눠 둔다.
//

import AppIntents
import CoreSpotlight
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
    /// 열어 달라는 내 도안. 첫 화면이 그 도안을 열고 비운다.
    var patternID: UUID?
}

struct MakePatternIntent: AppIntent {
    static let title = LocalizedStringResource("Make a Pattern", comment: "Siri: turn a photo into a bead or cross-stitch pattern")
    static let description = IntentDescription(
        LocalizedStringResource("Turns a photo into a bead or cross-stitch pattern. Opens the photo picker if no photo is given.", comment: "Siri: make pattern description")
    )
    static let openAppWhenRun = true

    /// 그림이 아닌 파일은 읽지 못해 걸러진다.
    @Parameter(title: LocalizedStringResource("Photo", comment: "Siri: photo parameter"),
               description: LocalizedStringResource("The photo to turn into a pattern", comment: "Siri: photo parameter description"))
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

// MARK: - 내 도안

struct PatternEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("Pattern", comment: "Siri/Spotlight: one saved bead or cross-stitch pattern")
    )
    static let defaultQuery = PatternQuery()

    let id: UUID
    let title: String
    /// "Perler · 29×29" 처럼 재료와 크기.
    let summary: String
    let createdAt: Date

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(summary)")
    }

    init(_ pattern: BeadPattern) {
        id = pattern.id
        title = pattern.title
        summary = "\(pattern.material.brandName) · \(pattern.width)×\(pattern.height)"
        createdAt = pattern.createdAt
    }
}

@available(iOS 18.0, *)
extension PatternEntity: IndexedEntity {
    var attributeSet: CSSearchableItemAttributeSet {
        let set = defaultAttributeSet
        set.contentDescription = summary
        set.contentCreationDate = createdAt
        return set
    }
}

struct PatternQuery: EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [PatternEntity] {
        let wanted = Set(identifiers)
        return PatternLibrary.read().filter { wanted.contains($0.id) }.map(PatternEntity.init)
    }

    /// 도안 이름에서 찾는다(대소문자 · 악센트 무시).
    func entities(matching string: String) async throws -> [PatternEntity] {
        let query = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        return PatternLibrary.read()
            .filter { $0.title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
            .map(PatternEntity.init)
    }

    /// 최근에 만든 도안부터 (저장 순서가 곧 최신순이다).
    func suggestedEntities() async throws -> [PatternEntity] {
        PatternLibrary.read().prefix(20).map(PatternEntity.init)
    }
}

/// 내 도안을 연다. Spotlight · Siri 결과를 누르면 여기로 온다.
struct OpenPatternIntent: OpenIntent {
    static let title = LocalizedStringResource("Open Pattern", comment: "Siri/Spotlight: open a saved pattern")
    static let description = IntentDescription(
        LocalizedStringResource("Opens one of your saved patterns.", comment: "Siri: open pattern description")
    )

    @Parameter(title: LocalizedStringResource("Pattern", comment: "Siri/Spotlight: one saved bead or cross-stitch pattern"),
               description: LocalizedStringResource("The saved pattern to open", comment: "Siri: pattern parameter description"))
    var target: PatternEntity

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        PatternRouter.shared.patternID = target.id
        return .result()
    }
}

enum PatternLibrary {
    /// PatternStore 와 같은 patterns.json 을 그대로 읽는다. 인텐트는 화면 없이도 돌기 때문이다.
    static func read() -> [BeadPattern] {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let data = try? Data(contentsOf: dir.appendingPathComponent("patterns.json")) else { return [] }
        return (try? JSONDecoder().decode([BeadPattern].self, from: data)) ?? []
    }

    /// Spotlight 에 싣는 도안을 지금 것에 맞춘다. 앱을 열 때와 뒤로 보낼 때 부른다.
    static func reindex() async {
        guard #available(iOS 18.0, *) else { return }
        let index = CSSearchableIndex.default()
        try? await index.deleteAppEntities(ofType: PatternEntity.self)
        try? await index.indexAppEntities(read().map(PatternEntity.init))
    }
}

// MARK: - Siri 문구

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
