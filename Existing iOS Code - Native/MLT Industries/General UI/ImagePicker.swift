//
//  ImagePicker.swift
//  CreatioKit
//
//  Created by Davis Allie on 1/4/2022.
//

import PhotosUI
import SwiftUI

public struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(imageBinding: $image)
    }
    
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        var imageBinding: Binding<UIImage?>
        internal init(imageBinding: Binding<UIImage?>) {
            self.imageBinding = imageBinding
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            defer {
                picker.dismiss(animated: true)
            }
            
            guard let result = results.first(where: { $0.itemProvider.canLoadObject(ofClass: UIImage.self) }) else {
                return
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                self.imageBinding.wrappedValue = image as? UIImage
            }
        }
    }
    
}
