//
//  PixelatedPhotoView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

/// Shows the pixelated photo effect
struct PixelatedPhotoView: View {
    
    @EnvironmentObject var manager: DataManager
    @State private var didShowInterstitial: Bool = false

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color(AppConfig.backgroundColor).ignoresSafeArea()
            VStack(spacing: 15) {
                HeaderView
                PixelatedImage().environmentObject(manager)
                PixelBoardSizeSelector
            }
        }
        /// Show interstitials and watermark if needed
        .onAppear {
            if !manager.isPremiumUser && !didShowInterstitial {
                didShowInterstitial = true
                //Interstitial.shared.showInterstitialAds()
            }
        }
    }
    
    /// Flow navigation header view
    private var HeaderView: some View {
        ZStack {
            HStack {
                Button {
                    manager.savePixelatedNFT()
                } label: { Image(systemName: "square.and.arrow.down") }
                Spacer()
                Button {
                    manager.fullScreenMode = nil
                } label: { Image(systemName: "xmark") }
            }.font(.system(size: 25))
            Text("Pixel Effect").font(.system(size: 20)).bold()
        }.padding(.horizontal).foregroundColor(.white)
    }
    
    // MARK: - Initial Pixel Canvas/Board size
    private var PixelBoardSizeSelector: some View {
        VStack(spacing: 15) {
            Text("Select Pixel Density").foregroundColor(.white)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                        ForEach(PixelBoardSize.allCases) {
                            type in PixelBoardSizeItem(type)
                        }
                    }
                    DownloadImage
                }
            }
        }.padding(.horizontal)
    }
    
    private func PixelBoardSizeItem(_ type: PixelBoardSize) -> some View {
        Button {
            manager.pixelBoardSize = type
            manager.applyPixelEffect(showFilterFlow: false)
        } label: {
            ZStack {
                Color.white.cornerRadius(15).opacity(manager.pixelBoardSize == type ? 1 : 0.3)
                Text(type.density).foregroundColor(manager.pixelBoardSize == type ? .black : .white)
                    .opacity(manager.pixelBoardSize == type ? 1 : 0.5)
            }
        }.frame(height: 60)
    }
    
    private var DownloadImage: some View {
        Button {
            manager.savePixelatedNFT()
        } label: {
            ZStack {
                Color(AppConfig.continueButtonColor).cornerRadius(15)
                Text("Download image").font(.system(size: 20, weight: .bold))
            }.foregroundColor(.white)
        }.frame(height: 60)
    }
    
    private var ApplyPixelDensity: some View {
        Button {
            manager.applyPixelEffect(showFilterFlow: false)
        } label: {
            ZStack {
                Color(AppConfig.continueButtonColor).cornerRadius(15)
                Text("Apply Effect").font(.system(size: 20, weight: .bold))
            }.foregroundColor(.white)
        }.frame(height: 60)
    }
}

// MARK: - Preview UI
struct PixelatedPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PixelatedPhotoView().environmentObject(DataManager())
    }
}

