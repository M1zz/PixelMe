//
//  PixelatedImage.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

/// Shows the pixelated image selected by the user
struct PixelatedImage: View {
    
    @EnvironmentObject var manager: DataManager
    @State var exportMode: Bool = false
    @State var exportImage: UIImage?
    
    // MARK: - Main rendering function
    var body: some View {
        let size = exportMode ? AppConfig.exportSize : UIScreen.main.bounds.width
        return ZStack {
            if let image = manager.pixelatedImage {
                Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size, alignment: .center)
                    .contentShape(Rectangle())
                    //.overlay(WatermarkLogoView)
            }
        }.frame(width: size, height: size, alignment: .center)
    }
    
    private var WatermarkLogoView: some View {
        ZStack {
            if manager.isPremiumUser == false {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(uiImage: UIImage(named: "watermark")!)
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60).shadow(color: Color.black.opacity(0.3), radius: 10)
                            .onTapGesture {
                                presentAlert(title: "Premium Feature", message: "To remove this logo, an in-app purchase is required. Go to the app settings to upgrade to the premium version", primaryAction: .ok)
                            }
                    }
                }.padding()
            }
        }
    }
}

// MARK: - Preview UI
struct PixelatedImage_Previews: PreviewProvider {
    static var previews: some View {
        PixelatedImage().environmentObject(DataManager())
    }
}
