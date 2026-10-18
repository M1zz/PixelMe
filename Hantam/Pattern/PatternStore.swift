//
//  PatternStore.swift
//  Hantam
//
//  내 도안 목록 — 문서 폴더의 JSON 한 개에 저장한다.
//

import Foundation

@MainActor
final class PatternStore: ObservableObject {
    static let shared = PatternStore()

    /// 무료로 저장해 둘 수 있는 도안 수.
    static let freeSaveLimit = 3

    @Published private(set) var patterns: [BeadPattern] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("patterns.json")
    }()

    private init() { load() }

    var canSaveMore: Bool {
        SubscriptionManager.shared.isProUser || patterns.count < Self.freeSaveLimit
    }

    func contains(_ pattern: BeadPattern) -> Bool {
        patterns.contains { $0.id == pattern.id }
    }

    /// 새 도안은 맨 앞에, 이미 있는 도안은 그 자리에서 바꾼다.
    func save(_ pattern: BeadPattern) {
        if let i = patterns.firstIndex(where: { $0.id == pattern.id }) {
            patterns[i] = pattern
        } else {
            patterns.insert(pattern, at: 0)
        }
        persist()
    }

    func delete(_ pattern: BeadPattern) {
        patterns.removeAll { $0.id == pattern.id }
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            patterns = try JSONDecoder().decode([BeadPattern].self, from: data)
        } catch {
            print("⚠️ [PatternStore] 도안 목록을 읽지 못함: \(error)")
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(patterns)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ [PatternStore] 도안 목록을 저장하지 못함: \(error)")
        }
    }
}
