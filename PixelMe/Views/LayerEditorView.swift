//
//  LayerEditorView.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI

struct LayerEditorView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color(AppConfig.backgroundColor).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Canvas preview
                    CanvasPreview

                    Divider()
                        .background(Color.gray)

                    // Layer list
                    LayerList

                    // Control buttons
                    ControlButtons
                }
            }
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveComposite()
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
            }
        }
    }

    // MARK: - Canvas Preview
    private var CanvasPreview: some View {
        ZStack {
            Color.gray.opacity(0.3)

            if let compositeImage = manager.layerManager.renderFinalImage() {
                Image(uiImage: compositeImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 300)
    }

    // MARK: - Layer List
    private var LayerList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(manager.layerManager.layers.indices.reversed(), id: \.self) { index in
                    LayerRow(index: index)
                }
            }
            .padding()
        }
    }

    // MARK: - Layer Row
    private func LayerRow(index: Int) -> some View {
        let layer = manager.layerManager.layers[index]

        return HStack(spacing: 12) {
            // Visibility toggle
            Button {
                manager.layerManager.toggleLayerVisibility(at: index)
            } label: {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundColor(layer.isVisible ? .blue : .gray)
                    .frame(width: 30)
            }

            // Thumbnail
            if let image = layer.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }

            // Layer info
            VStack(alignment: .leading, spacing: 4) {
                Text(layer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("\(Int(layer.opacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(layer.blendMode.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)

                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            // Selection indicator
            if manager.layerManager.selectedLayerIndex == index {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(manager.layerManager.selectedLayerIndex == index ? Color.blue.opacity(0.2) : Color(AppConfig.toolBackgroundColor))
        )
        .onTapGesture {
            manager.layerManager.selectedLayerIndex = index
        }
    }

    // MARK: - Control Buttons
    private var ControlButtons: some View {
        HStack(spacing: 12) {
            // Add layer
            Button {
                if let image = manager.selectedImage {
                    manager.layerManager.addLayer(name: "Layer \(manager.layerManager.layers.count + 1)", image: image)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "plus.square")
                    Text("Add")
                        .font(.caption)
                }
            }

            Divider()
                .frame(height: 30)

            // Duplicate layer
            Button {
                if let index = manager.layerManager.selectedLayerIndex {
                    manager.layerManager.duplicateLayer(at: index)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Duplicate")
                        .font(.caption)
                }
            }
            .disabled(manager.layerManager.selectedLayerIndex == nil)

            Divider()
                .frame(height: 30)

            // Delete layer
            Button {
                if let index = manager.layerManager.selectedLayerIndex {
                    manager.layerManager.removeLayer(at: index)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Delete")
                        .font(.caption)
                }
            }
            .disabled(manager.layerManager.selectedLayerIndex == nil || manager.layerManager.layers.count <= 1)
            .foregroundColor(.red)

            Divider()
                .frame(height: 30)

            // Merge menu
            Menu {
                Button {
                    if let index = manager.layerManager.selectedLayerIndex {
                        manager.layerManager.mergeLayerDown(at: index)
                    }
                } label: {
                    Label("Merge Down", systemImage: "arrow.down.square")
                }
                .disabled(manager.layerManager.selectedLayerIndex == nil || manager.layerManager.selectedLayerIndex == 0)

                Button {
                    manager.layerManager.mergeVisibleLayers()
                } label: {
                    Label("Merge Visible", systemImage: "eye.square")
                }
                .disabled(manager.layerManager.visibleLayerCount < 2)

                Divider()

                Button(role: .destructive) {
                    manager.layerManager.flattenLayers()
                } label: {
                    Label("Flatten All", systemImage: "square.3.layers.3d.down.right")
                }
                .disabled(manager.layerManager.layers.count < 2)
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.3.layers.3d.down.right")
                    Text("Merge")
                        .font(.caption)
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color(AppConfig.toolBackgroundColor))
    }

    // MARK: - Actions
    private func saveComposite() {
        if let finalImage = manager.layerManager.renderFinalImage() {
            manager.pixelatedImage = finalImage
            presentAlert(title: "Success", message: "Layers merged successfully")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct LayerEditorView_Previews: PreviewProvider {
    static var previews: some View {
        LayerEditorView()
            .environmentObject(DataManager())
    }
}
