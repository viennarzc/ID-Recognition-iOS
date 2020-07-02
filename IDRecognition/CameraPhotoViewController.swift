//
//  CameraPhotoViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/2/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit

class CameraPhotoViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupImagePicker()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  func setupImagePicker() {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      imagePicker.sourceType = .camera
    } else {
      imagePicker.sourceType = .savedPhotosAlbum
    }
    
    self.present(imagePicker, animated: true, completion: nil)
  }
  
}

extension CameraPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
  }
  
}
