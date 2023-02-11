//
//  CameraCapture.swift
//  
//
//  Created by Davis Allie on 2/4/2022.
//

import SwiftUI
import UIKit

public struct CameraCapture: View {
    
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public var body: some View {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            _CameraCapture(image: $image)
                .ignoresSafeArea()
        } else {
            VStack {
                Text("Camera unavailable")
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
    }
    
}

struct _CameraCapture: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imageBinding: $image)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var imageBinding: Binding<UIImage?>
        internal init(imageBinding: Binding<UIImage?>) {
            self.imageBinding = imageBinding
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            defer {
                picker.dismiss(animated: true)
            }
            
            guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
                return
            }
            
            self.imageBinding.wrappedValue = image
        }
    }
    
}
