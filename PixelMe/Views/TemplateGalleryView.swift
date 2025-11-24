//
//  TemplateGalleryView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct TemplateGalleryView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: TemplateCategory = .profile

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category selector
                    CategorySelector

                    // Template grid
                    TemplateGrid
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Category Selector
    private var CategorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TemplateCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: selectedCategory == category ? .bold : .regular))
                            .foregroundColor(selectedCategory == category ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.blue : Color(AppConfig.toolBackgroundColor))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(AppConfig.backgroundColor))
    }

    // MARK: - Template Grid
    private var TemplateGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2), spacing: 15) {
                ForEach(selectedCategory.templates) { template in
                    TemplateCard(template: template)
                }
            }
            .padding()
        }
    }

    // MARK: - Template Card
    private func TemplateCard(template: Template) -> some View {
        Button {
            applyTemplate(template)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Template preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(template.aspectRatio, contentMode: .fit)

                    VStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)

                        Text("\(Int(template.size.width))x\(Int(template.size.height))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Label("\(template.pixelSize)px", systemImage: "square.grid.3x3")
                        if template.hasBorder {
                            Label("Border", systemImage: "rectangle.dashed")
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(AppConfig.toolBackgroundColor))
            )
        }
    }

    // MARK: - Apply Template
    private func applyTemplate(_ template: Template) {
        guard let image = manager.selectedImage else {
            presentAlert(title: "No Image", message: "Please select an image first")
            return
        }

        // Apply template
        if let processedImage = manager.templateManager.applyTemplate(to: image, template: template) {
            manager.selectedImage = processedImage

            // Apply recommended palette if available
            if let paletteName = template.recommendedPalette,
               let palette = ColorPaletteType.allCases.first(where: { $0.rawValue.lowercased() == paletteName.lowercased() }) {
                manager.selectedColorPalette = palette
            }

            // Set pixel size based on template
            if let pixelSize = PixelBoardSize.allCases.first(where: { $0.count == template.pixelSize }) {
                manager.pixelBoardSize = pixelSize
            }

            // Apply effect
            manager.applyPixelEffect(showFilterFlow: false)

            presentAlert(title: "Template Applied", message: "Template '\(template.name)' has been applied")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct TemplateGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateGalleryView()
            .environmentObject(DataManager())
    }
}
