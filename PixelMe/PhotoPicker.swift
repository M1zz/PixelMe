//
//  PhotoPicker.swift
//  PixelMe
//
//  Created by hyunho lee on 2023/06/30.
//

import SwiftUI
import PhotosUI

// MARK: - Allow users to select only 1 photo
struct PhotoPicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    let didSelect: (_ image: UIImage?) -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.didSelect((info[.editedImage] as? UIImage)?.crop)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
