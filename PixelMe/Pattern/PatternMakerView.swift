//
//  PatternMakerView.swift
//  Hantam
//
//  사진 한 장 → 재료·크기·색 수를 고르며 바로 미리 보고 → 도안 만들기.
//

import SwiftUI
import PhotosUI

struct PatternMakerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscription = SubscriptionManager.shared
    @ObservedObject private var store = PatternStore.shared

    @State private var pickerItem: PhotosPickerItem?
    @State private var original: UIImage?
    @State private var cutout: UIImage?
    @State private var removeBackground = false
    @State private var isRemovingBackground = false
    @State private var settings = PatternSettings()
    @State private var preview: BeadPattern?
    @State private var previewImage: UIImage?
    @State private var isWorking = false
    @State private var renderTask: Task<Void, Never>?
    @State private var paywallReason: PaywallReason?
    @State private var created: BeadPattern?

    /// 사진 고르기를 바로 열지 (홈에서 들어올 때).
    private let startWithPicker: Bool
    private let initialImage: UIImage?
    @State private var showPicker = false

    init(startWithPicker: Bool = true, initialImage: UIImage? = nil) {
        self.startWithPicker = startWithPicker
        self.initialImage = initialImage
    }

    private var isPro: Bool { subscription.isProUser }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hantamBackground.ignoresSafeArea()
                if original == nil {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            previewCard
                            materialSection
                            sizeSection
                            colorSection
                            if settings.material.kind == .thread { fabricSection }
                            backgroundSection
                            Spacer(minLength: 90)
                        }
                        .padding(16)
                    }
                    .safeAreaInset(edge: .bottom) { createButton }
                }
            }
            .navigationTitle(Text("New pattern"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if original != nil {
                    ToolbarItem(placement: .primaryAction) {
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                        }
                        .accessibilityLabel(Text("Choose another photo"))
                    }
                }
            }
            .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
            .onChange(of: pickerItem) { _, item in loadPhoto(item) }
            .onChange(of: settings) { _, _ in schedulePreview() }
            .onChange(of: removeBackground) { _, on in applyBackgroundChoice(on) }
            .onAppear {
                if let initialImage, original == nil {
                    original = initialImage
                    schedulePreview()
                } else if startWithPicker && original == nil {
                    showPicker = true
                }
            }
            .sheet(item: $paywallReason) { reason in
                PaywallView(isProUser: .constant(false), reason: reason)
            }
            .fullScreenCover(item: $created, onDismiss: { dismiss() }) { pattern in
                PatternDetailView(pattern: pattern)
            }
        }
        .tint(.hantamAccent)
    }

    // MARK: - 사진 없음

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 54))
                .foregroundStyle(Color.hantamAccent)
            Text("Pick a photo to turn into a pattern")
                .font(.headline)
                .foregroundStyle(Color.hantamInk)
                .multilineTextAlignment(.center)
            Text("Pets, faces, logos and characters all work. Photos with a clear subject turn out best.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Text("Choose a photo")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 260, minHeight: 50)
                    .background(Color.hantamAccent, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(32)
    }

    // MARK: - 미리보기

    private var previewCard: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(Color.hantamCard)
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .padding(12)
                        .accessibilityLabel(Text("Pattern preview"))
                }
                if isWorking || isRemovingBackground {
                    ProgressView().controlSize(.large)
                }
            }
            .frame(height: 300)

            if let preview {
                Text(PatternRenderer.infoLines(for: preview).dropFirst().joined(separator: " · "))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - 재료

    private var materialSection: some View {
        section(title: "Material") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Material", selection: $settings.material) {
                    ForEach(PatternMaterial.allCases) { m in
                        Text(m.brandName).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settings.material) { _, m in
                    settings.longestSide = min(max(settings.longestSide, m.minSide), isPro ? m.proMaxSide : m.freeMaxSide)
                    if !m.sizePresets.contains(settings.longestSide) { settings.longestSide = m.defaultSide }
                    settings.maxColors = m.defaultMaxColors
                    HantamEvent.track("pattern_material.\(m.rawValue)")
                }
                Text(settings.material.kindName)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - 크기

    private var sizeSection: some View {
        let m = settings.material
        return section(title: "Size") {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(m.sizePresets, id: \.self) { side in
                            let locked = !isPro && side > m.freeMaxSide
                            Button {
                                if locked {
                                    paywallReason = .patternSize
                                } else {
                                    settings.longestSide = side
                                }
                            } label: {
                                sizeChip(side: side, locked: locked, selected: settings.longestSide == side)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Stepper(value: $settings.longestSide, in: m.minSide...(isPro ? m.proMaxSide : m.freeMaxSide)) {
                    Text("Longest side: \(settings.longestSide)")
                        .font(.subheadline)
                }
                if !isPro {
                    Button {
                        paywallReason = .patternSize
                    } label: {
                        Label(m.kind == .bead
                              ? LocalizedStringKey("Free patterns fit one pegboard. Pro goes up to 4 × 4 boards.")
                              : LocalizedStringKey("Free patterns go up to 40 stitches. Pro goes up to 200."),
                              systemImage: "lock.fill")
                            .font(.footnote)
                            .foregroundStyle(Color.hantamAccent)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }

    private func sizeChip(side: Int, locked: Bool, selected: Bool) -> some View {
        let m = settings.material
        return VStack(spacing: 2) {
            HStack(spacing: 3) {
                Text("\(side)")
                    .font(.system(size: 16, weight: .bold))
                if locked { Image(systemName: "lock.fill").font(.system(size: 10)) }
            }
            if let b = m.boardSize {
                let n = (side + b - 1) / b
                Text("\(n * n) boards")
                    .font(.system(size: 11))
            } else {
                let cm = Double(side) / (Double(settings.fabricCount) / 2.54)
                Text(String(format: "%.0f cm", cm))
                    .font(.system(size: 11))
            }
        }
        .foregroundStyle(selected ? Color.white : Color.hantamInk)
        .frame(minWidth: 64, minHeight: 50)
        .padding(.horizontal, 6)
        .background(selected ? Color.hantamAccent : Color.hantamCard, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hantamInk.opacity(0.1)))
        .accessibilityElement(children: .combine)
    }

    // MARK: - 색 수

    private var colorSection: some View {
        section(title: "Colors") {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Up to \(settings.maxColors) colors")
                        .font(.subheadline)
                    Spacer()
                }
                Slider(value: Binding(
                    get: { Double(settings.maxColors) },
                    set: { settings.maxColors = Int($0.rounded()) }
                ), in: 2...50, step: 1)
                Text("Fewer colors means fewer bags of beads to buy.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var fabricSection: some View {
        section(title: "Fabric") {
            Picker("Fabric", selection: $settings.fabricCount) {
                ForEach([11, 14, 16, 18], id: \.self) { ct in
                    Text("\(ct)-count").tag(ct)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var backgroundSection: some View {
        section(title: "Background") {
            Toggle(isOn: $removeBackground) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remove background")
                    Text("Keep only the subject and leave the rest empty.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(isRemovingBackground)
        }
    }

    // MARK: - 만들기

    private var createButton: some View {
        Button {
            createPattern()
        } label: {
            Text("Make pattern")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color.hantamAccent, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(preview == nil || isWorking)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.hantamBackground.opacity(0.95))
    }

    private func section<Content: View>(title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 동작

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            original = image
            cutout = nil
            removeBackground = false
            HantamEvent.track("pattern_photo_picked")
            schedulePreview()
        }
    }

    private func applyBackgroundChoice(_ on: Bool) {
        guard on, cutout == nil, let original else { schedulePreview(); return }
        isRemovingBackground = true
        BackgroundRemovalManager.removeBackgroundSmart(from: original) { result in
            DispatchQueue.main.async {
                isRemovingBackground = false
                if let result {
                    cutout = result
                } else {
                    removeBackground = false
                    presentAlert(title: NSLocalizedString("Couldn’t find a subject", comment: "Background removal failed title"),
                                 message: NSLocalizedString("Try a photo where the subject stands out from the background.", comment: "Background removal failed message"))
                }
                schedulePreview()
            }
        }
    }

    private var sourceImage: UIImage? {
        removeBackground ? (cutout ?? original) : original
    }

    private func schedulePreview() {
        guard let source = sourceImage else { return }
        renderTask?.cancel()
        isWorking = true
        let s = settings
        renderTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if Task.isCancelled { return }
            let result = await Task.detached(priority: .userInitiated) { () -> (BeadPattern, UIImage)? in
                guard let p = PatternEngine.makePattern(from: source, settings: s, title: "") else { return nil }
                let cell = max(4, min(24, (900 / CGFloat(p.longestSide)).rounded()))
                return (p, PatternRenderer.image(for: p, cell: cell, style: .preview, showGrid: false))
            }.value
            if Task.isCancelled { return }
            preview = result?.0
            previewImage = result?.1
            isWorking = false
        }
    }

    private func createPattern() {
        guard var p = preview else { return }
        let n = store.patterns.count + 1
        p.title = String(format: NSLocalizedString("My pattern %lld", comment: "Default pattern title"), n)
        p.id = UUID()
        p.createdAt = Date()
        if store.canSaveMore { store.save(p) }
        HantamEvent.track("pattern_created.\(p.material.rawValue)")
        created = p
    }
}

extension PaywallReason: Identifiable {
    var id: String { rawValue }
}
