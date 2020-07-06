//
//  VisionKitDocumentViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/6/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit
import VisionKit

class VisionKitDocumentViewController: UIViewController {
  override func viewDidLoad() {
     super.viewDidLoad()
     // Do any additional setup after loading the view.
   }
   
   override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
     
     scanDocument()
   }
   
   func scanDocument() {
     let scanVC = VNDocumentCameraViewController()
     scanVC.delegate = self
     
     present(scanVC, animated: true, completion: nil)
   }
}

extension VisionKitDocumentViewController: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    controller.dismiss(animated: true, completion: nil)
    
    if scan.pageCount >= 1 {
      scan.imageOfPage(at: 0)
    }
    
    
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true) {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    controller.dismiss(animated: true, completion: nil)
  }
  
}


