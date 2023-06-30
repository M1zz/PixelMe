//
//  AppConfig.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import UIKit
import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
//    /// This is the AdMob Interstitial ad id
//    /// Test App ID: ca-app-pub-3940256099942544~1458002511
//    static let adMobAdId: String = "ca-app-pub-3940256099942544/4411468910"
//
    // MARK: - Settings flow items
    static let emailSupport = "leeo@kakao.com"
    static let privacyURL: URL = URL(string: "https://www.google.com/")!
    static let termsAndConditionsURL: URL = URL(string: "https://www.google.com/")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/idXXXXXXXXX")!
    
    // MARK: - UI Styles
    static let backgroundColor: UIColor = UIColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    static let toolBackgroundColor: UIColor = UIColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let continueButtonColor: UIColor = UIColor(#colorLiteral(red: 0.1895111597, green: 0.6577079403, blue: 0.9686274529, alpha: 1))
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "PixelNFT.Premium"
    
    // MARK: - Image export size at 2x
    static let exportSize: CGFloat = 500 /// this will export the image at 1000x1000 resolution
}
