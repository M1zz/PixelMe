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
            switch type {
            case .createNFT:
                CreatorContentView().environmentObject(manager)
            case .applyFilter:
                PixelatedPhotoView().environmentObject(manager)
            case .settings:
                Text("Setting")
                //SettingsContentView().environmentObject(manager)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { image in
                showPhotoPicker = false
                manager.selectedImage = image
                manager.applyPixelEffect()
            }
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
                    //manager.fullScreenMode = nil
                    showPhotoPicker = true
                } label: {
                    //Image(systemName: "xmark")
                    Text("Pixelize")
                        .font(.callout)
                }
            }.font(.system(size: 25))
            Text("Pixel Creator").font(.system(size: 20)).bold()
        }.padding(.horizontal).foregroundColor(.white)
    }
    
    /// Pixels grid view
    private func PixelsGridView(height: CGFloat = UIScreen.main.bounds.width, export: Bool = false) -> some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<manager.pixelBoardSize.count, id: \.self) { column in
                    Pixels(forColumn: column, height: height, export: export)
                }
            }
        }
        .frame(height: height)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { dragGesture in
            let point = dragGesture.location
            let pixelSize = UIScreen.main.bounds.width/CGFloat(manager.pixelBoardSize.count)
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
            ForEach(0..<manager.pixelBoardSize.count, id: \.self) { row in
                ZStack {
                    Rectangle().foregroundColor(backgroundColor)
                    if export == false {
                        Rectangle().stroke(invertGridLinesColor ? Color.white : Color.black, lineWidth: 1)
                            .opacity(showGridView ? 1 : 0)
                    }
                    if filledPixels.contains("\(column)_\(row)") {
                        Rectangle().foregroundColor(filledColors["\(column)_\(row)"])
                    }
                }.frame(height: height/CGFloat(manager.pixelBoardSize.count))
            }
        }
    }
    
    private var WatermarkLogoView: some View {
        ZStack {
            if didSelectBoardSize && showLogoWatermark {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(uiImage: UIImage(named: "watermark")!)
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60).shadow(color: Color.black.opacity(0.3), radius: 10)
                            .opacity(shouldHideLogoWatermark ? 0.2 : 1)
                            .onTapGesture { shouldHideLogoWatermark.toggle() }
                    }
                }.padding()
            }
        }
    }
    
    // MARK: - Initial Pixel Canvas/Board size
    private var PixelBoardSizeSelector: some View {
        VStack(spacing: 15) {
            Text("Select Board Size").foregroundColor(.white)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        ForEach(PixelBoardSize.allCases) {
                            type in PixelBoardSizeItem(type)
                        }
                    }
                    ChooseButton
                }
            }
        }.padding(.horizontal)
    }
    
    private func PixelBoardSizeItem(_ type: PixelBoardSize) -> some View {
        Button {
            manager.pixelBoardSize = type
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
    
    private var ChooseButton: some View {
        Button {
            didSelectBoardSize = true
        } label: {
            ZStack {
                Color(AppConfig.continueButtonColor).cornerRadius(15)
                Text("Choose").font(.system(size: 20, weight: .bold))
            }.foregroundColor(.white)
        }.frame(height: 60)
    }
    
    // MARK: - Pixel Colors and Tools
    private var PixelBoardToolsView: some View {
        VStack(spacing: 15) {
            Text("Select Pixel Colors & Tools").foregroundColor(.white)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        PixelColorView
                        BackgroundColorView
                        RemoveWatermarkView
                        EraserToolView
                    }
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
}

// MARK: - Preview UI
struct CreatorContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorContentView().environmentObject(DataManager())
    }
}
