//
//  PatternDetailView.swift
//  Hantam
//
//  도안 보기·고치기·내보내기. 칸을 눌러 색을 바꾸고, 색 목록에서 한 색을 통째로 바꾸고,
//  인쇄용 PDF · 이미지 · 구매 목록으로 내보낸다.
//

import SwiftUI
import LeeoKit

struct PatternDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscription = SubscriptionManager.shared
    @ObservedObject private var store = PatternStore.shared

    @State private var pattern: BeadPattern
    @State private var style: PatternDisplayStyle = .preview
    @State private var chartImage: UIImage?
    @State private var zoom: CGFloat = 1
    @State private var baseZoom: CGFloat = 1
    @State private var isEditing = false
    @State private var brush: Int = 0
    @State private var undoStack: [[Int]] = []
    @State private var replacing: ReplaceTarget?
    @State private var paywallReason: PaywallReason?
    @State private var shareItems: ShareItems?
    @State private var showRename = false
    @State private var titleDraft = ""
    @State private var copiedList = false
    /// 방금 만든 도안인가. 그때만 응원 카드를 세운다.
    private let justCreated: Bool

    init(pattern: BeadPattern, initialStyle: PatternDisplayStyle = .preview, initialZoom: CGFloat = 1,
         justCreated: Bool = false) {
        self.justCreated = justCreated
        _pattern = State(initialValue: pattern)
        _style = State(initialValue: initialStyle)
        _zoom = State(initialValue: initialZoom)
        _baseZoom = State(initialValue: initialZoom)
    }

    private var isPro: Bool { subscription.isProUser }
    private var isSaved: Bool { store.contains(pattern) }

    /// 화면에서 한 칸의 기본 크기 (pt).
    private var baseCell: CGFloat {
        let fit = (UIScreen.main.bounds.width - 32) / CGFloat(pattern.width)
        return max(6, min(28, fit))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hantamBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        if !isSaved { saveLimitBanner }
                        chart
                        stylePicker
                        if isEditing { brushPalette }
                        infoCard
                        // 이미 Pro 인 사람이 도안을 또 하나 만든 순간에만 응원을 부탁한다.
                        // 아직 안 산 사람에게는 페이월이 맞는 길이다.
                        if justCreated, isPro, let tipJar = subscription.tipJar {
                            LeeoTipAskSlot<HantamSpec>(tipJar: tipJar, reached: HantamTipMoments.reachedNow)
                        }
                        exportCard
                        colorList
                        Spacer(minLength: 30)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(pattern.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    if isEditing && !undoStack.isEmpty {
                        Button { undo() } label: { Image(systemName: "arrow.uturn.backward") }
                            .accessibilityLabel(Text("Undo"))
                    }
                    Button(isEditing ? "Finish editing" : "Edit") {
                        isEditing.toggle()
                        if !isEditing { persist() }
                    }
                    Menu {
                        Button { titleDraft = pattern.title; showRename = true } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        if isSaved {
                            Button(role: .destructive) { store.delete(pattern); dismiss() } label: {
                                Label("Delete pattern", systemImage: "trash")
                            }
                        }
                    } label: { Image(systemName: "ellipsis.circle") }
                    .accessibilityLabel(Text("More"))
                }
            }
            .alert("Rename", isPresented: $showRename) {
                TextField("Pattern name", text: $titleDraft)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    let t = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty { pattern.title = t; persist() }
                }
            }
            .sheet(item: $replacing) { target in
                ColorReplaceSheet(pattern: pattern, target: target) { newColor in
                    apply(replace: target, with: newColor)
                }
            }
            .sheet(item: $paywallReason) { reason in
                PaywallView(isProUser: .constant(false), reason: reason)
            }
            .sheet(item: $shareItems) { items in
                ActivityView(items: items.items)
            }
            .onAppear(perform: rerender)
            .onChange(of: style) { _, _ in rerender() }
            .onChange(of: pattern) { _, _ in rerender() }
        }
        .tint(.hantamAccent)
    }

    // MARK: - 도안 판

    private var chart: some View {
        let cell = baseCell * zoom
        let w = CGFloat(pattern.width) * cell
        let h = CGFloat(pattern.height) * cell
        return ScrollView([.horizontal, .vertical], showsIndicators: true) {
            Group {
                if let chartImage {
                    Image(uiImage: chartImage)
                        .resizable()
                        .interpolation(style == .preview ? .high : .none)
                        .frame(width: w, height: h)
                        .onTapGesture(coordinateSpace: .local) { loc in
                            guard isEditing else { return }
                            paint(at: loc, cell: cell)
                        }
                } else {
                    ProgressView().frame(width: w, height: h)
                }
            }
            .padding(8)
        }
        .frame(height: min(max(h + 16, 220), 460))
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isEditing ? Color.hantamAccent : Color.clear, lineWidth: 2))
        .gesture(
            MagnificationGesture()
                .onChanged { v in zoom = min(6, max(0.5, baseZoom * v)) }
                .onEnded { _ in baseZoom = zoom }
        )
        // VoiceOver 에는 그림 하나로 보인다 — 크기·색 수를 읽어 주고, 색 바꾸기는 아래 색 목록에서 한다.
        // (칸 하나하나를 손가락 없이 고치는 길은 없다. 두 번 탭이 엉뚱한 칸을 칠하지 않게 자식 동작을 숨긴다.)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Pattern chart"))
        .accessibilityValue(Text(PatternRenderer.infoLines(for: pattern).joined(separator: ", ")))
        .accessibilityAddTraits(.isImage)
        .accessibilityHint(Text("Swap colors from the color list below."))
    }

    private var stylePicker: some View {
        Picker("View", selection: $style) {
            Text(pattern.material.kind == .bead ? "Beads" : "Stitches").tag(PatternDisplayStyle.preview)
            Text("Colors").tag(PatternDisplayStyle.color)
            Text("Symbols").tag(PatternDisplayStyle.symbol)
        }
        .pickerStyle(.segmented)
    }

    /// 고치기 붓 — 도안에 쓰인 색 + 빈칸.
    private var brushPalette: some View {
        let symbols = pattern.symbols
        return VStack(alignment: .leading, spacing: 8) {
            Text("Tap a square to change it")
                .font(.footnote)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button { brush = -1 } label: {
                        ZStack {
                            Circle().stroke(Color.hantamInk.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                            Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.secondary)
                        }
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.hantamAccent, lineWidth: brush == -1 ? 3 : 0).padding(-3))
                    }
                    .accessibilityLabel(Text("Empty"))
                    .accessibilityAddTraits(brush == -1 ? .isSelected : [])
                    ForEach(Array(pattern.colors.enumerated()), id: \.offset) { i, c in
                        Button { brush = i } label: {
                            Circle().fill(c.color)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color.black.opacity(0.1)))
                                // 색만으로 고르지 않게 — 기호 보기·색 목록과 같은 기호를 얹는다.
                                .overlay(Text(symbols[i] ?? "")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(c.isLight ? Color.black : Color.white))
                                .overlay(Circle().stroke(Color.hantamAccent, lineWidth: brush == i ? 3 : 0).padding(-3))
                        }
                        .accessibilityLabel(Text("\(c.code) \(c.name)"))
                        .accessibilityAddTraits(brush == i ? .isSelected : [])
                        .accessibilityInputLabels([Text(c.code), Text(c.name)])
                    }
                }
                .padding(4)
            }
        }
    }

    // MARK: - 정보 · 내보내기

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(PatternRenderer.infoLines(for: pattern), id: \.self) { line in
                Text(line)
                    .font(line == PatternRenderer.infoLines(for: pattern).first ? .headline : .subheadline)
                    .foregroundStyle(Color.hantamInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 16))
    }

    private var exportCard: some View {
        VStack(spacing: 10) {
            Button { exportPDF() } label: {
                HStack {
                    Image(systemName: "printer.fill").accessibilityHidden(true)
                    Text("Printable pattern (PDF)")
                    Spacer()
                    if !isPro { proBadge }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
                .background(Color.hantamAccentFill, in: RoundedRectangle(cornerRadius: 14))
            }
            HStack(spacing: 10) {
                Button { shareImage() } label: {
                    Label("Share image", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 12))
                }
                Button { copyShoppingList() } label: {
                    Label(copiedList ? "Copied" : "Copy shopping list",
                          systemImage: copiedList ? "checkmark" : "cart")
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.hantamInk)
            if !isPro {
                Text("Free images carry a small Hantam mark.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var proBadge: some View {
        Text("PRO")
            .font(.caption2.weight(.heavy))
            .foregroundStyle(Color.hantamAccentFill)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Color.white, in: Capsule())
    }

    private var saveLimitBanner: some View {
        Button { paywallReason = .patternSaveLimit } label: {
            HStack(spacing: 10) {
                Image(systemName: "tray.full.fill").accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("This pattern isn’t saved")
                        .font(.subheadline.weight(.semibold))
                    Text("Free keeps \(PatternStore.freeSaveLimit) patterns. Pro keeps them all.")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right").accessibilityHidden(true)
            }
            .foregroundStyle(Color.hantamInk)
            .padding(12)
            .background(Color.hantamMustard.opacity(0.25), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 색 목록

    private var colorList: some View {
        let symbols = pattern.symbols
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Colors you need")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("Tap to swap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 8)
            ForEach(pattern.colorUsage, id: \.index) { u in
                Button { replacing = ReplaceTarget(index: u.index) } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6).fill(u.color.color)
                                .frame(width: 34, height: 34)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.1)))
                            Text(symbols[u.index] ?? "")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(u.color.isLight ? Color.black : Color.white)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(u.color.code).font(.subheadline.weight(.semibold))
                            Text(u.color.name).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(u.count)")
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(Color.hantamInk)
                    .padding(.vertical, 7)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityHint(Text("Swap this color for another"))
                .accessibilityInputLabels([Text(u.color.code), Text(u.color.name)])
                Divider()
            }
            Text("Perler, Hama, Artkal and DMC are trademarks of their owners. Colors on screen may differ slightly from the real thing.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
        }
        .padding(14)
        .background(Color.hantamCard, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 동작

    private func rerender() {
        let p = pattern, s = style
        let px = max(6, min(28, (2400 / CGFloat(p.longestSide)).rounded()))
        Task.detached(priority: .userInitiated) {
            let img = PatternRenderer.image(for: p, cell: px, style: s, showGrid: s != .preview)
            await MainActor.run { chartImage = img }
        }
    }

    private func paint(at loc: CGPoint, cell: CGFloat) {
        let x = Int(loc.x / cell), y = Int(loc.y / cell)
        guard x >= 0, y >= 0, x < pattern.width, y < pattern.height else { return }
        let i = pattern.index(x: x, y: y)
        guard pattern.cells[i] != brush else { return }
        undoStack.append(pattern.cells)
        if undoStack.count > 50 { undoStack.removeFirst() }
        pattern.cells[i] = brush
        HantamEvent.track("pattern_edited")
    }

    private func undo() {
        guard let last = undoStack.popLast() else { return }
        pattern.cells = last
    }

    private func apply(replace target: ReplaceTarget, with newColor: PatternColor) {
        undoStack.append(pattern.cells)
        if let existing = pattern.colors.firstIndex(of: newColor), existing != target.index {
            // 이미 쓰는 색으로 바꾸면 두 색을 합친다.
            pattern.cells = pattern.cells.map { $0 == target.index ? existing : $0 }
        } else {
            pattern.colors[target.index] = newColor
        }
        persist()
        HantamEvent.track("pattern_color_swapped")
    }

    private func persist() {
        if isSaved { store.save(pattern) }
    }

    private func exportPDF() {
        guard isPro else { paywallReason = .patternPDF; return }
        let data = PatternRenderer.pdfData(for: pattern)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(safeFileName(pattern.title) + ".pdf")
        do {
            try data.write(to: url, options: .atomic)
            shareItems = ShareItems(items: [url])
            HantamEvent.track("pattern_pdf_exported.\(pattern.material.rawValue)")
        } catch {
            presentAlert(title: NSLocalizedString("Couldn’t make the PDF", comment: "PDF export failed"),
                         message: error.localizedDescription)
        }
    }

    private func shareImage() {
        let style = self.style == .preview ? PatternDisplayStyle.preview : self.style
        let img = PatternRenderer.shareImage(for: pattern, style: style, watermark: !isPro)
        shareItems = ShareItems(items: [img])
        HantamEvent.track(isPro ? "pattern_image_shared" : "pattern_image_shared.watermarked")
    }

    private func copyShoppingList() {
        UIPasteboard.general.string = PatternRenderer.shoppingList(for: pattern)
        copiedList = true
        HantamEvent.track("pattern_list_copied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiedList = false }
    }

    private func safeFileName(_ s: String) -> String {
        let bad = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleaned = s.components(separatedBy: bad).joined(separator: "-")
        return cleaned.isEmpty ? "Hantam" : cleaned
    }
}

// MARK: - 색 바꾸기

struct ReplaceTarget: Identifiable {
    let index: Int
    var id: Int { index }
}

struct ColorReplaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let pattern: BeadPattern
    let target: ReplaceTarget
    let onPick: (PatternColor) -> Void
    @State private var query = ""

    private var current: PatternColor { pattern.colors[target.index] }

    /// 지금 색과 가까운 색부터.
    private var candidates: [PatternColor] {
        let base = PatternEngine.Lab(r: current.r, g: current.g, b: current.b)
        let all = pattern.material.palette.sorted {
            PatternEngine.deltaE94(base, .init(r: $0.r, g: $0.g, b: $0.b)) <
            PatternEngine.deltaE94(base, .init(r: $1.r, g: $1.g, b: $1.b))
        }
        guard !query.isEmpty else { return all }
        return all.filter { $0.code.localizedCaseInsensitiveContains(query) || $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(candidates) { c in
                Button {
                    onPick(c)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 6).fill(c.color)
                            .frame(width: 30, height: 30)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.1)))
                        VStack(alignment: .leading) {
                            Text(c.code).font(.subheadline.weight(.semibold))
                            Text(c.name).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if c == current { Image(systemName: "checkmark").foregroundStyle(Color.hantamAccent).accessibilityHidden(true) }
                    }
                }
                .foregroundStyle(.primary)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(c == current ? .isSelected : [])
                .accessibilityInputLabels([Text(c.code), Text(c.name)])
            }
            .searchable(text: $query, prompt: Text("Color number or name"))
            .navigationTitle(Text("Swap \(current.code)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .tint(.hantamAccent)
    }
}

// MARK: - 공유

struct ShareItems: Identifiable {
    let id = UUID()
    let items: [Any]
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - 응원 부탁 순간

/// 팁을 부탁할 순간 — 저장해 둔 도안 수. 큰 것부터.
@MainActor
enum HantamTipMoments {
    static let patterns = [50, 20, 10]

    static func reached(patterns count: Int) -> [LeeoTipMoment] {
        patterns.filter { count >= $0 }.map {
            LeeoTipMoment(id: "patterns.\($0)",
                          message: String(format: NSLocalizedString("You've made %lld patterns with Hantam",
                                                                    comment: "Tip ask card: how many patterns saved so far"),
                                          count))
        }
    }

    static var reachedNow: [LeeoTipMoment] { reached(patterns: PatternStore.shared.patterns.count) }
}
