//
//  View+Extension.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/01.
//

import SwiftUI

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
