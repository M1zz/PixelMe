//
//  CreatorContentView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

/// Pixel creator flow to draw pixels
struct CreatorContentView: View {

    @EnvironmentObject var manager: DataManager
    @State private var filledPixels: [String] = [String]()
    @State private var filledColors: [String: Color] = [String: Color]()
    @State private var currentColor: Color = .black
    @State private var backgroundColor: Color = .white
    @State private var eraserToolEnabled: Bool = false
    @State private var showGridView: Bool = true
    @State private var showLogoWatermark: Bool = true
    @State private var shouldHideLogoWatermark: Bool = false
    @State private var invertGridLinesColor: Bool = false
    @State private var didSelectBoardSize: Bool = false
    @State private var didShowInterstitial: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showPhotoPreview: Bool = false
    @State private var showBoardSizeChanger: Bool = false
    @State private var showWatermarkPicker: Bool = false

    // Home screen and navigation
    @State private var showHomeScreen: Bool = true
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var showSampleGallery: Bool = false
    @State private var selectedSample: SamplePixelArt? = nil
    @State private var referenceSample: SamplePixelArt? = nil  // For follow-along drawing
    @State private var showReferenceImage: Bool = true

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()

            if showHomeScreen {
                // Home Screen - Main menu
                HomeScreenView
            } else {
                // Drawing Screen
                VStack(spacing: 15) {
                    DrawingHeaderView
                    ZStack {
                        PixelsGridView()

                        // Hint overlay when board not selected
                        if !didSelectBoardSize {
                            GridHintOverlay
                        }
                    }

                    // Reference image for follow-along mode
                    if let sample = referenceSample, showReferenceImage, didSelectBoardSize {
                        ReferenceImageView(sample: sample)
                    }

                    if didSelectBoardSize {
                        PixelBoardToolsView
                    } else {
                        PixelBoardSizeSelector
                    }
                }
            }
        }
        // Onboarding for first-time users
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        // Sample gallery
        .sheet(isPresented: $showSampleGallery) {
            SampleArtGalleryView(selectedSample: $selectedSample) { sample in
                loadSampleArt(sample)
            }
        }
        .fullScreenCover(item: $manager.fullScreenMode) { type in
            Group {
                switch type {
                case .createPixelArt:
                    CreatorContentView().environmentObject(manager)
                        .onAppear { print("🖼️ [CreatorContentView] CreatorContentView appeared") }
                case .applyFilter:
                    PixelatedPhotoView().environmentObject(manager)
                        .onAppear { print("🖼️ [CreatorContentView] PixelatedPhotoView appeared!") }
                case .settings:
                    Text("Setting")
                        .onAppear { print("🖼️ [CreatorContentView] Settings appeared") }
                    //SettingsContentView().environmentObject(manager)
                }
            }
            .onAppear {
                print("🖼️ [CreatorContentView] fullScreenMode triggered: \(type)")
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { image in
                print("📸 [CreatorContentView] Photo selected from picker")
                print("📸 [CreatorContentView] Image is: \(image != nil ? "NOT NIL" : "NIL")")

                // Store the image in DataManager (more stable than @State)
                manager.tempPhotoForPreview = image
                print("📸 [CreatorContentView] manager.tempPhotoForPreview set")

                // Don't manually dismiss - let PhotoPicker handle it
                // showPhotoPicker = false

                // Wait a bit for the sheet to close, then show preview
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("📸 [CreatorContentView] Checking image before showing preview...")
                    print("📸 [CreatorContentView] manager.tempPhotoForPreview is: \(manager.tempPhotoForPreview != nil ? "NOT NIL" : "NIL")")
                    showPhotoPreview = true
                    print("📸 [CreatorContentView] Setting showPhotoPreview = true")
                }
            }
        }
        .sheet(isPresented: $showPhotoPreview) {
            Group {
                if let selectedImage = manager.tempPhotoForPreview {
                    PhotoPreviewView(selectedImage: selectedImage)
                        .environmentObject(manager)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.large])
                        .onAppear {
                            print("📸 [CreatorContentView] PhotoPreviewView appeared")
                        }
                } else {
                    Color.clear
                        .onAppear {
                            print("⚠️ [CreatorContentView] manager.tempPhotoForPreview is nil!")
                        }
                }
            }
        }
        .sheet(isPresented: $showBoardSizeChanger) {
            BoardSizeChangerSheet
        }
        .sheet(isPresented: $showWatermarkPicker) {
            PhotoPicker { image in
                if let selectedImage = image {
                    manager.saveCustomWatermark(selectedImage)
                    print("✅ [CreatorContentView] Watermark saved")
                }
            }
        }
        .onChange(of: manager.shouldLoadPixelGrid) { oldValue, shouldLoad in
            // Load pixel data when returning from PixelatedPhotoView
            if shouldLoad, let pixelData = manager.pixelGridData {
                print("🎨 [CreatorContentView] Loading pixel data from PixelatedPhotoView")

                // Set board size as already selected
                didSelectBoardSize = true

                // Load pixel colors into the grid
                filledColors = pixelData
                filledPixels = Array(pixelData.keys)

                // Reset the flag
                manager.shouldLoadPixelGrid = false

                print("🎨 [CreatorContentView] Loaded \(filledPixels.count) pixels")
                print("🎨 [CreatorContentView] Board size: \(manager.pixelBoardSize?.rawValue ?? "nil")")
            }
        }
        .onChange(of: manager.shouldDismissPhotoPreview) { oldValue, shouldDismiss in
            if shouldDismiss {
                showPhotoPreview = false
                manager.shouldDismissPhotoPreview = false
            }
        }
        .onChange(of: manager.useCustomWatermark) { oldValue, newValue in
            // Save watermark preference
            UserDefaults.standard.set(newValue, forKey: "useCustomWatermark")
            print("💾 [CreatorContentView] Watermark toggle saved: \(newValue)")
        }
    }

    // MARK: - Home Screen

    /// Home screen with two main options
    private var HomeScreenView: some View {
        VStack(spacing: 0) {
            // Header
            Text("Pixel Creator")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 60)
                .padding(.bottom, 30)

            ScrollView {
                VStack(spacing: 25) {
                    // Main action buttons
                    VStack(spacing: 15) {
                        // Follow Along Drawing Button
                        Button {
                            showSampleGallery = true
                        } label: {
                            HomeActionButton(
                                icon: "paintbrush.pointed.fill",
                                title: "Follow Along",
                                subtitle: "Pick a sample and draw along",
                                color: .purple
                            )
                        }

                        // Pixelate Photo Button
                        Button {
                            showPhotoPicker = true
                        } label: {
                            HomeActionButton(
                                icon: "photo.fill",
                                title: "Pixelate Photo",
                                subtitle: "Turn your photo into pixel art",
                                color: .blue
                            )
                        }

                        // Free Drawing Button
                        Button {
                            referenceSample = nil
                            showHomeScreen = false
                        } label: {
                            HomeActionButton(
                                icon: "scribble.variable",
                                title: "Free Drawing",
                                subtitle: "Create your own pixel art",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Sample Preview Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sample Gallery")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(SamplePixelArtCollection.all) { sample in
                                    Button {
                                        startFollowAlongDrawing(sample)
                                    } label: {
                                        SamplePreviewCard(sample: sample)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)

                    Spacer(minLength: 50)
                }
            }
        }
    }

    /// Start follow-along drawing with a sample
    private func startFollowAlongDrawing(_ sample: SamplePixelArt) {
        referenceSample = sample
        manager.pixelBoardSize = sample.boardSize
        filledPixels.removeAll()
        filledColors.removeAll()
        backgroundColor = sample.backgroundColor
        showHomeScreen = false
        didSelectBoardSize = true
    }

    // MARK: - Drawing Screen Header

    /// Header for drawing screen with back button
    private var DrawingHeaderView: some View {
        ZStack {
            HStack {
                // Back to home button
                Button {
                    showHomeScreen = true
                    didSelectBoardSize = false
                    referenceSample = nil
                } label: {
                    Image(systemName: "house.fill")
                }

                // Save button
                Button {
                    manager.savePixelGrid(view: AnyView(PixelsGridView(height: AppConfig.exportSize, export: true)))
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }

                Spacer()

                // Toggle reference image (if in follow-along mode)
                if referenceSample != nil {
                    Button {
                        showReferenceImage.toggle()
                    } label: {
                        Image(systemName: showReferenceImage ? "eye.fill" : "eye.slash.fill")
                    }
                }
            }.font(.system(size: 22))

            Text(referenceSample != nil ? "Follow Along" : "Free Drawing")
                .font(.system(size: 18, weight: .bold))
        }
        .padding(.horizontal)
        .foregroundColor(.white)
        .padding(.top, 50)
    }

    // MARK: - Reference Image View

    /// Shows the sample reference while drawing
    private func ReferenceImageView(sample: SamplePixelArt) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Reference: \(sample.name)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
            }

            HStack(spacing: 15) {
                // Reference image
                SampleArtPreview(sample: sample)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )

                // Tips
                VStack(alignment: .leading, spacing: 4) {
                    Text("Look at the reference and draw!")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Tap eye icon to hide/show")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(AppConfig.toolBackgroundColor).opacity(0.5))
    }

    /// Hint overlay for empty grid
    private var GridHintOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))

            VStack(spacing: 8) {
                Text("Select a board size below")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                Text("or tap the grid icon to load a sample")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
    }

    /// Load sample pixel art into the editor
    private func loadSampleArt(_ sample: SamplePixelArt) {
        // Set board size
        manager.pixelBoardSize = sample.boardSize

        // Set colors
        filledColors = sample.pixels
        filledPixels = sample.filledPixels
        backgroundColor = sample.backgroundColor

        // Activate the board
        withAnimation(.easeInOut(duration: 0.3)) {
            didSelectBoardSize = true
        }

        print("🎨 [CreatorContentView] Loaded sample: \(sample.name)")
    }
    
    /// Pixels grid view
    private func PixelsGridView(height: CGFloat = UIScreen.main.bounds.width, export: Bool = false) -> some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<(manager.pixelBoardSize?.count ?? 16), id: \.self) { column in
                    Pixels(forColumn: column, height: height, export: export)
                }
            }
        }
        .frame(height: height)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { dragGesture in
            guard let boardSize = manager.pixelBoardSize else { return }
            let point = dragGesture.location
            let pixelSize = UIScreen.main.bounds.width/CGFloat(boardSize.count)
            let height = Int(height)
            let width = height
            let y = Int(point.y / pixelSize)
            let x = Int(point.x / pixelSize)
            guard y < height && x < width && y >= 0 && x >= 0 else { return }
            filledColors["\(x)_\(y)"] = currentColor
            if eraserToolEnabled { filledPixels.removeAll(where: { $0 == "\(x)_\(y)" }) } else {
                filledPixels.append("\(x)_\(y)")
            }
        }).disabled(!didSelectBoardSize).overlay(WatermarkLogoView)
    }
    
    private func Pixels(forColumn column: Int, height: CGFloat, export: Bool = false) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<(manager.pixelBoardSize?.count ?? 16), id: \.self) { row in
                ZStack {
                    Rectangle().foregroundColor(backgroundColor)
                    if export == false {
                        Rectangle().stroke(invertGridLinesColor ? Color.white : Color.black, lineWidth: 1)
                            .opacity(showGridView ? 1 : 0)
                    }
                    if filledPixels.contains("\(column)_\(row)") {
                        Rectangle().foregroundColor(filledColors["\(column)_\(row)"])
                    }
                }.frame(height: height/CGFloat(manager.pixelBoardSize?.count ?? 16))
            }
        }
    }
    
    private var WatermarkLogoView: some View {
        ZStack {
            if didSelectBoardSize && manager.useCustomWatermark {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if let watermarkImage = manager.getWatermarkImage() {
                            Image(uiImage: watermarkImage)
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.black.opacity(0.3), radius: 10)
                        }
                    }
                }.padding()
            }
        }
    }
    
    // MARK: - Initial Pixel Canvas/Board size
    private var PixelBoardSizeSelector: some View {
        VStack(spacing: 15) {
            VStack(spacing: 8) {
                Text("Select Board Size")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Choose a size to start drawing pixel art")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        ForEach(PixelBoardSize.allCases) {
                            type in PixelBoardSizeItem(type)
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }

    private func PixelBoardSizeItem(_ type: PixelBoardSize) -> some View {
        let isSelected = manager.pixelBoardSize == type
        return Button {
            manager.pixelBoardSize = type
            // Auto-activate the board immediately for instant drawing
            withAnimation(.easeInOut(duration: 0.3)) {
                didSelectBoardSize = true
            }
        } label: {
            ZStack {
                Color.white.cornerRadius(15)
                    .opacity(isSelected ? 1 : 0.3)
                Text(type.rawValue)
                    .foregroundColor(isSelected ? .black : .white)
                    .opacity(isSelected ? 1 : 0.5)
            }
        }.frame(height: 60)
    }

    // MARK: - Pixel Colors and Tools
    private var PixelBoardToolsView: some View {
        VStack(spacing: 15) {
            Text("Select Pixel Colors & Tools").foregroundColor(.white)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        BoardSizeChangeView
                        PixelColorView
                        BackgroundColorView
                        EraserToolView
                    }
                    WatermarkView
                    ShowHideGridView
                    InvertGridColorView
                }.foregroundColor(.white)
                Spacer(minLength: 50)
            }
        }.padding(.horizontal)
    }
    
    private var PixelColorView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Pixel Color").font(.system(size: 18))
                Spacer()
                ColorPicker("", selection: $currentColor).labelsHidden()
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }
    
    private var BackgroundColorView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Board Color").font(.system(size: 18))
                Spacer()
                ColorPicker("", selection: $backgroundColor).labelsHidden()
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }
    
    private var EraserToolView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Eraser").font(.system(size: 18))
                Spacer()
                Toggle(isOn: $eraserToolEnabled) { EmptyView() }
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }

    private var WatermarkView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Watermark").font(.system(size: 18))
                Spacer()

                // Image select button
                Button {
                    showWatermarkPicker = true
                } label: {
                    HStack(spacing: 4) {
                        if manager.customWatermarkImage != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        }
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }

                // Toggle
                Toggle(isOn: $manager.useCustomWatermark) { EmptyView() }
                    .disabled(manager.customWatermarkImage == nil)
                    .labelsHidden()
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }

    private var RemoveWatermarkView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Logo").font(.system(size: 18))
                Spacer()
                Toggle(isOn: $showLogoWatermark.onChange({ value in
                    if false {//!manager.isPremiumUser {
                        presentAlert(title: "Premium Feature", message: "To remove this logo, an in-app purchase is required. Go to the app settings to upgrade to the premium version", primaryAction: UIAlertAction(title: "OK", style: .default, handler: { _ in
                            showLogoWatermark = true
                            shouldHideLogoWatermark = false
                        }))
                    }
                })) { EmptyView() }.labelsHidden()
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }
    
    private var ShowHideGridView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Show Board Grid Lines").font(.system(size: 18))
                Spacer()
                Toggle(isOn: $showGridView) { EmptyView() }.labelsHidden()
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }
    
    private var InvertGridColorView: some View {
        ZStack {
            Color(AppConfig.toolBackgroundColor).cornerRadius(15)
            HStack {
                Text("Invert Grid Lines Color").font(.system(size: 18))
                Spacer()
                Toggle(isOn: $invertGridLinesColor) { EmptyView() }.labelsHidden()
            }.padding(.horizontal, 15)
        }.frame(height: 60)
    }

    private var BoardSizeChangeView: some View {
        Button {
            showBoardSizeChanger = true
        } label: {
            ZStack {
                Color(AppConfig.toolBackgroundColor).cornerRadius(15)
                HStack {
                    Text("Board Size").font(.system(size: 18))
                    Spacer()
                    Text(manager.pixelBoardSize?.rawValue ?? "N/A")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }.padding(.horizontal, 15)
            }
        }.frame(height: 60)
    }

    private var BoardSizeChangerSheet: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()
            VStack(spacing: 20) {
                // Header
                HStack {
                    Spacer()
                    Text("Change Board Size")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        showBoardSizeChanger = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                .padding()

                Text("Warning: Changing board size will clear your current drawing")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        ForEach(PixelBoardSize.allCases) { type in
                            Button {
                                manager.pixelBoardSize = type
                                // Clear the drawing
                                filledPixels.removeAll()
                                filledColors.removeAll()
                                showBoardSizeChanger = false
                            } label: {
                                ZStack {
                                    Color.white.cornerRadius(15)
                                        .opacity(manager.pixelBoardSize == type ? 1 : 0.3)
                                    Text(type.rawValue)
                                        .foregroundColor(manager.pixelBoardSize == type ? .black : .white)
                                        .opacity(manager.pixelBoardSize == type ? 1 : 0.5)
                                }
                            }.frame(height: 60)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Home Action Button

/// Large action button for home screen
struct HomeActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(18)
        .background(Color(AppConfig.toolBackgroundColor))
        .cornerRadius(15)
    }
}

// MARK: - Sample Preview Card

/// Small card showing sample pixel art preview
struct SamplePreviewCard: View {
    let sample: SamplePixelArt

    var body: some View {
        VStack(spacing: 8) {
            // Pixel art preview
            SampleArtPreview(sample: sample)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            // Name
            Text(sample.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 90)
    }
}

// MARK: - Preview UI
struct CreatorContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorContentView().environmentObject(DataManager())
    }
}
