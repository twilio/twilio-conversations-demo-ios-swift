//
//  ImagePicker.swift
//  ConversationsApp
//
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

///  https://augmentedcode.io/2020/11/22/using-an-image-picker-in-swiftui/
struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias SourceType = UIImagePickerController.SourceType
    typealias CompletionHandler = (UIImage?, NSURL?, String?) -> Void

    let sourceType: SourceType
    let completionHandler: CompletionHandler

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        viewController.sourceType = sourceType
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(completionHandler: completionHandler)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completionHandler: CompletionHandler

        init(completionHandler: @escaping CompletionHandler) {
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image: UIImage? = {
                return info[.originalImage] as? UIImage
            }()
            let url = {
                return info[.imageURL] as? NSURL
            }()
            
            let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
            
            completionHandler(image, url, fileUrl?.lastPathComponent ?? "")
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil, nil, nil)
        }
    }
}
