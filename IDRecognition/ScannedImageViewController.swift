//
//  ScannedImageViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 6/26/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit
import Vision

class ScannedImageViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!

  var image: UIImage?
  
  // Image parameters for reuse throughout app
  var imageWidth: CGFloat = 0
  var imageHeight: CGFloat = 0

  // Layer into which to draw bounding box paths.
  var pathLayer: CALayer?

  lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
    let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
    // Customize & configure the request to detect only certain rectangles.
    rectDetectRequest.maximumObservations = 1 // Vision currently supports up to 16.
    rectDetectRequest.minimumConfidence = 0.6 // Be confident.
    rectDetectRequest.minimumAspectRatio = 0.1 // height / width
    return rectDetectRequest
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  //MARK: Vision Completion Handlers

  func handleDetectedRectangles(request: VNRequest, error: Error?) {

    DispatchQueue.main.async {
      guard let drawLayer = self.pathLayer,
        let results = request.results as? [VNRectangleObservation] else {
          return
      }
      self.draw(rectangles: results, onImageWithBounds: drawLayer.bounds)

      drawLayer.setNeedsDisplay()
    }


  }

  fileprivate func draw(rectangles: [VNRectangleObservation], onImageWithBounds bounds: CGRect) {
    CATransaction.begin()
    for observation in rectangles {
      
      let rectBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)

      let rectLayer = shapeLayer(color: .blue, frame: rectBox)

      // Add to pathLayer on top of image.
      pathLayer?.addSublayer(rectLayer)
    }
    CATransaction.commit()
  }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    imageView.image = image

    // Convert from UIImageOrientation to CGImagePropertyOrientation.

    if image == nil {
      return
    }

    let cgOrientation = CGImagePropertyOrientation(image!.imageOrientation)

    // Fire off request based on URL of chosen photo.
    guard let cgImage = image!.cgImage else {
      return
    }
    performVisionRequest(image: cgImage,
      orientation: cgOrientation)
    
    
    let fullImageWidth = CGFloat(cgImage.width)
    let fullImageHeight = CGFloat(cgImage.height)

    let imageFrame = imageView.frame
    let widthRatio = fullImageWidth / imageFrame.width
    let heightRatio = fullImageHeight / imageFrame.height

    // ScaleAspectFit: The image will be scaled down according to the stricter dimension.
    let scaleDownRatio = max(widthRatio, heightRatio)

    // Cache image dimensions to reference when drawing CALayer paths.
    imageWidth = fullImageWidth / scaleDownRatio
    imageHeight = fullImageHeight / scaleDownRatio
    
    // Prepare pathLayer to hold Vision results.
    let xLayer = (imageFrame.width - imageWidth) / 2
    let yLayer = imageView.frame.minY + (imageFrame.height - imageHeight) / 2
    let drawingLayer = CALayer()
    drawingLayer.bounds = CGRect(x: xLayer, y: yLayer, width: imageWidth, height: imageHeight)
    drawingLayer.anchorPoint = CGPoint.zero
    drawingLayer.position = CGPoint(x: xLayer, y: yLayer)
    drawingLayer.opacity = 0.5
    pathLayer = drawingLayer
    self.view.layer.addSublayer(pathLayer!)
  }

  /// - Tag: PerformRequests
  fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {

    // Fetch desired requests based on switch status.
    let requests = [rectangleDetectionRequest]
    // Create a request handler.
    let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                    orientation: .down,
      options: [:])

    // Send the requests to the request handler.
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try imageRequestHandler.perform(requests)
      } catch let error as NSError {
        print("Failed to perform image request: \(error)")
//        self.presentAlert("Image Request Failed", error: error)
        return
      }
    }
  }

  // MARK: - Path-Drawing

  fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {

    let imageWidth = bounds.width
    let imageHeight = bounds.height

    // Begin with input rect.
    var rect = forRegionOfInterest

    // Reposition origin.
    rect.origin.x *= imageWidth
    rect.origin.x += bounds.origin.x
    rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y

    // Rescale normalized coordinates.
    rect.size.width *= imageWidth
    rect.size.height *= imageHeight

    return rect
  }

  fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
    // Create a new layer.
    let layer = CAShapeLayer()

    // Configure layer's appearance.
    layer.fillColor = nil // No fill to show boxed object
    layer.shadowOpacity = 0
    layer.shadowRadius = 0
    layer.borderWidth = 2

    // Vary the line color according to input.
    layer.borderColor = color.cgColor

    // Locate the layer.
    layer.anchorPoint = .zero
    layer.frame = frame
    layer.masksToBounds = true

    // Transform the layer to have same coordinate system as the imageView underneath it.
    layer.transform = CATransform3DMakeScale(1, -1, 1)

    return layer
  }

}
