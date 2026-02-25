//
//  View+Extension.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

// MARK: - Color Extension for brightness detection
extension Color {
    /// Returns true if the color is considered "light" (for contrast purposes)
    var isLight: Bool {
        guard let components = UIColor(self).cgColor.components else { return false }
        let red = components[0]
        let green = components.count > 1 ? components[1] : components[0]
        let blue = components.count > 2 ? components[2] : components[0]
        // Calculate luminance using standard formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5
    }
}

extension View {
    func image(size: CGSize? = nil) -> UIImage {
        func generateScreenshot(_ controller: UIHostingController<AnyView>) -> UIImage {
            let view = controller.view
            let targetSize = controller.view.intrinsicContentSize
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            let format = UIGraphicsImageRendererFormat()
            format.scale = size?.width == AppConfig.exportSize ? 2 : 1
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
            return renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }

        if let exportSize = size {
            return generateScreenshot(UIHostingController(rootView: AnyView(self.frame(width: exportSize.width, height: exportSize.height).ignoresSafeArea().fixedSize(horizontal: true, vertical: true))))
        }
        
        return generateScreenshot(UIHostingController(rootView: AnyView(self.ignoresSafeArea().fixedSize(horizontal: true, vertical: true))))
    }
}
