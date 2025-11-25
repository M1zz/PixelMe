//
//  CreatorContentView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

/// NFT Pixel creator flow to draw pixels
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

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()
            VStack(spacing: 15) {
                HeaderView
                PixelsGridView()
                if didSelectBoardSize {
                    PixelBoardToolsView
                } else {
                    PixelBoardSizeSelector
                }
            }
        }
        .fullScreenCover(item: $manager.fullScreenMode) { type in
            Group {
                switch type {
                case .createNFT:
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

    /// Flow navigation header view
    private var HeaderView: some View {
        ZStack {
            HStack {
                Button {
                    manager.savePixelGrid(view: AnyView(PixelsGridView(height: AppConfig.exportSize, export: true)))
                } label: { Image(systemName: "square.and.arrow.down") }
                Spacer()
                Button {
                    showPhotoPicker = true
                } label: {
                    Image(systemName: "photo.on.rectangle.angled")
                }
            }.font(.system(size: 25))
            Text("Pixel Creator").font(.system(size: 20)).bold()
        }.padding(.horizontal).foregroundColor(.white)
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

// MARK: - Preview UI
struct CreatorContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorContentView().environmentObject(DataManager())
    }
}
