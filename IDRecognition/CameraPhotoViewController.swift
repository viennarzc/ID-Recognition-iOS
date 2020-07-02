//
//  CameraPhotoViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/2/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit


class CameraPhotoViewController: UIViewController {
  private var capturedImage: UIImage?

  @IBOutlet weak var imageView: UIImageView!
  // Layer into which to draw bounding box paths.
  var pathLayer: CALayer?

  // Image parameters for reuse throughout app
  var imageWidth: CGFloat = 0
  var imageHeight: CGFloat = 0

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

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    if segue.identifier == "goToScannedImage",
      let scannedVC = segue.destination as? ScannedImageViewController,
      let capturedImage = capturedImage
      {
      scannedVC.image = capturedImage
    }
  }
  
  @IBAction func didTapOpenCamera(_ sender: Any) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .camera

    present(imagePicker, animated: true, completion: nil)
  }

}

extension CameraPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.navigationController?.popViewController(animated: true)
    }
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    // Extract chosen image.
    let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage

    self.capturedImage = originalImage

    // Dismiss the picker to return to original view controller.
    dismiss(animated: true, completion: nil)

    performSegue(withIdentifier: "goToScannedImage", sender: self)
  }

}
