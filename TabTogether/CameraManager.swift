//
//  CameraManager.swift
//  TabTogether
//
//  Created by Sultan Lodi on 8/12/25.
//

import UIKit
import AVFoundation
import PhotosUI

class CameraManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private weak var presentingViewController: UIViewController?
    private var completion: ((UIImage?) -> Void)?
    
    func presentCamera(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.presentingViewController = viewController
        self.completion = completion
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        
        viewController.present(picker, animated: true)
    }
    
    func presentPhotoLibrary(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.presentingViewController = viewController
        self.completion = completion
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        
        viewController.present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        completion?(image)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion?(nil)
        picker.dismiss(animated: true)
    }
}
