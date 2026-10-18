//
//  Watermark.swift
//  Hantam
//
//  무료 사용자의 내보낸 그림에 붙는 "Made with Hantam" 표시와 앱 주소.
//

import UIKit

enum Watermark {

    /// 공유 문구에 붙이는 앱 주소.
    static let appStoreURL = "https://apps.apple.com/app/id6449769987"

    /// 이미지 오른쪽 아래에 "Made with Hantam" + 앱 주소를 그린다 (스레드 무관).
    static func applyWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { context in
            image.draw(at: .zero)

            let mainFontSize: CGFloat = max(image.size.width * 0.028, 13)
            let linkFontSize: CGFloat = max(image.size.width * 0.02, 10)
            let padding: CGFloat = mainFontSize * 0.7

            // 메인 텍스트: "Made with Hantam"
            let mainText = "Made with Hantam"
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: mainFontSize, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
            let mainSize = (mainText as NSString).size(withAttributes: mainAttributes)

            // 링크 텍스트: 앱스토어 단축 URL
            let linkText = "apps.apple.com/app/id6449769987"
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: linkFontSize, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.55)
            ]
            let linkSize = (linkText as NSString).size(withAttributes: linkAttributes)

            let boxWidth = max(mainSize.width, linkSize.width) + padding * 2
            let lineSpacing: CGFloat = mainFontSize * 0.2
            let boxHeight = mainSize.height + linkSize.height + lineSpacing + padding * 2

            // 배경 박스 (우하단, 라운드 코너)
            let bgRect = CGRect(
                x: image.size.width - boxWidth - padding,
                y: image.size.height - boxHeight - padding,
                width: boxWidth,
                height: boxHeight
            )

            UIColor.black.withAlphaComponent(0.45).setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: mainFontSize * 0.4).fill()

            // 메인 텍스트
            let mainPoint = CGPoint(
                x: bgRect.origin.x + (boxWidth - mainSize.width) / 2,
                y: bgRect.origin.y + padding
            )
            (mainText as NSString).draw(at: mainPoint, withAttributes: mainAttributes)

            // 링크 텍스트
            let linkPoint = CGPoint(
                x: bgRect.origin.x + (boxWidth - linkSize.width) / 2,
                y: mainPoint.y + mainSize.height + lineSpacing
            )
            (linkText as NSString).draw(at: linkPoint, withAttributes: linkAttributes)
        }
    }
}
