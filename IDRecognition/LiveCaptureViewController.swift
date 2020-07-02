//
//  ViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 6/26/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class LiveCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {

  @IBOutlet weak var observationLabel: UILabel!
  private var requests = [VNRequest]()
  private var rectangleLastObservation: VNRectangleObservation?
  private var capturedRectangleObservation: VNRectangleObservation?
  private var lastObservation: VNDetectedObjectObservation?
  private var sequenceHandler = VNSequenceRequestHandler()
  private var maskLayer: CAShapeLayer = CAShapeLayer()
  private var maskLayer2: CAShapeLayer = CAShapeLayer()

  private let session = AVCaptureSession()
  private var previewLayer: AVCaptureVideoPreviewLayer!
  private let queue = DispatchQueue(label: "com.vvc.IDRecognition.vision")

  private var overlayView = UIView()
  private var overlayView2 = UIView()

  private var overlayer = CALayer()
  private var overlayer2 = CALayer()

  var capturePhotoOutput: AVCapturePhotoOutput?
  var videoOutput: AVCaptureVideoDataOutput?

  var capturedImage: UIImage?

  lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
    let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
    // Customize & configure the request to detect only certain rectangles.
    rectDetectRequest.maximumObservations = 1 // Vision currently supports up to 16.
    rectDetectRequest.minimumConfidence = 0.6 // Be confident.
    rectDetectRequest.minimumAspectRatio = 0.3 // height / width
    return rectDetectRequest
  }()

  @IBOutlet weak var captureView: UIView!

  override func viewDidLoad() {
    overlayView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
    overlayView.layer.borderColor = UIColor.clear.cgColor
    overlayView.layer.borderWidth = 3
    overlayView.layer.cornerRadius = 5
    overlayView.backgroundColor = .clear

    view.addSubview(overlayView)

    overlayView2.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
    overlayView2.layer.borderColor = UIColor.systemTeal.cgColor
    overlayView2.layer.borderWidth = 3
    overlayView2.layer.cornerRadius = 5
    overlayView2.backgroundColor = .clear

//    view.addSubview(overlayView2)

    super.viewDidLoad()

    //AVVideo Capture setup and starting the capture
    self.setupAvCaptureSession()
    self.startVideoCapture()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer.frame = self.captureView.bounds
  }

  //MARK: AVCaptureSession Methods

  func setupAvCaptureSession() {
    do {
      previewLayer = AVCaptureVideoPreviewLayer(session: session)
      captureView.layer.addSublayer(previewLayer)

      capturePhotoOutput = AVCapturePhotoOutput()

      let input = try AVCaptureDeviceInput(device: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!)

      let output = AVCaptureVideoDataOutput()
      output.setSampleBufferDelegate(self, queue: queue)
      previewLayer.videoGravity = .resizeAspectFill
      
      if let connection = output.connection(with: .video), connection.isVideoOrientationSupported {
        connection.videoOrientation = .portrait
      }
  
      session.addInput(input)
      session.addOutput(output)
      

      if let stillImageOutput = capturePhotoOutput {
        session.addOutput(stillImageOutput)
      }

    } catch {
      print(error)
    }
  }

  func startVideoCapture() {
    if session.isRunning {
      print("session already exists")
      return
    }
    session.startRunning()
  }

  func handle(buffer: CMSampleBuffer) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }

    do {
      try sequenceHandler.perform(
        [rectangleDetectionRequest],
        on: pixelBuffer,
        orientation: .left)
    } catch {
      print(error.localizedDescription)
    }

  }

  func handleLastObservation(buffer sampleBuffer: CMSampleBuffer) {
    guard
    // get the CVPixelBuffer out of the CMSampleBuffer
    let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
      // make sure that there is a previous observation we can feed into the request
    let lastObservation = self.lastObservation
      else { return }

    // create the request
    let request = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: self.handleVisionRequestUpdate)

    // set the accuracy to high
    // this is slower, but it works a lot better
    request.trackingLevel = .accurate

    // perform the request
    do {
      try self.sequenceHandler.perform([request], on: pixelBuffer)
    } catch {
      print("Throws: \(error)")
    }

  }

  private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
    // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
    DispatchQueue.main.async {
      // make sure we have an actual result
      guard let newObservation = request.results?.first as? VNDetectedObjectObservation else { return }

      // prepare for next loop
      self.lastObservation = newObservation

      // check the confidence level before updating the UI
      guard newObservation.confidence >= 0.3 else {
        // hide the rectangle when we lose accuracy so the user knows something is wrong
        self.overlayView.frame = .zero
        return
      }

      // calculate view rect
      var transformedRect = newObservation.boundingBox
      transformedRect.origin.y = 1 - transformedRect.origin.y
      let convertedRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
      // move the highlight view
      self.overlayView.frame = convertedRect

    }
  }

  //MARK: Vision Completion Handlers

  func handleDetectedRectangles(request: VNRequest, error: Error?) {
    guard let results = request.results as? [VNRectangleObservation] else { return }

    for observation in results {
//      self.rectangleLastObservation = observation

      makeOverlay2(from: observation)
//      makeOverlay4(from: observation)
//      makeOverlay3(from: observation)
//      makeOverlay(from: observation)

      //perspective correction

    }
    if let obser = results.first {
      self.capturedRectangleObservation = obser
    }

  }

  //Most Accurate
  func makeOverlay2(from observation: VNRectangleObservation) {

    DispatchQueue.main.async {

      let bottomLeftPoint = VNImagePointForNormalizedPoint(
        observation.bottomLeft,
        Int(self.previewLayer.frame.width),
        Int(self.previewLayer.frame.height))

      let bottomRightPoint = VNImagePointForNormalizedPoint(
        observation.bottomRight,
        Int(self.previewLayer.frame.width),
        Int(self.previewLayer.frame.height))

      let topLeftPoint = VNImagePointForNormalizedPoint(
        observation.topLeft,
        Int(self.previewLayer.frame.width),
        Int(self.previewLayer.frame.height))

      let topRightPoint = VNImagePointForNormalizedPoint(
        observation.topRight,
        Int(self.previewLayer.frame.width),
        Int(self.previewLayer.frame.height))

      let points = [topLeftPoint, topRightPoint, bottomRightPoint, bottomLeftPoint]

      let bezierPath = UIBezierPath()

      bezierPath.move(to: points[0])
      bezierPath.addLine(to: points[0])
      bezierPath.addLine(to: points[1])
      bezierPath.addLine(to: points[2])
      bezierPath.addLine(to: points[3])
      bezierPath.close()

      //Path one
      self.maskLayer.path = bezierPath.cgPath
      self.maskLayer.strokeColor = UIColor.red.cgColor
      self.maskLayer.fillColor = UIColor.clear.cgColor
      self.maskLayer.cornerRadius = 25
      self.maskLayer.lineWidth = 1.0
      self.previewLayer.addSublayer(self.maskLayer)
    }

  }

  func makeOverlay3(from observation: VNRectangleObservation) {

    DispatchQueue.main.async {

      let boundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)


      let p1 = boundingBoxOnScreen.topLeadingPoint
      let p2 = boundingBoxOnScreen.topTrailingPoint
      let p3 = boundingBoxOnScreen.bottomLeadingPoint
      let p4 = boundingBoxOnScreen.bottomTrailingPoint

      //path two

      let blp = VNImagePointForNormalizedPoint(p3, Int(self.previewLayer.frame.width), Int(self.previewLayer.frame.height))

      let brp = VNImagePointForNormalizedPoint(p4, Int(self.previewLayer.frame.width), Int(self.previewLayer.frame.height))

      let tlp = VNImagePointForNormalizedPoint(p1, Int(self.previewLayer.frame.width), Int(self.previewLayer.frame.height))

      let trp = VNImagePointForNormalizedPoint(p2, Int(self.previewLayer.frame.width), Int(self.previewLayer.frame.height))

      let bezierPath2 = UIBezierPath()

      bezierPath2.move(to: blp)
      bezierPath2.addLine(to: blp)
      bezierPath2.addLine(to: brp)
      bezierPath2.addLine(to: tlp)
      bezierPath2.addLine(to: trp)
      bezierPath2.close()

      self.maskLayer2.strokeColor = UIColor.yellow.cgColor
      self.maskLayer2.fillColor = UIColor.clear.cgColor
      self.maskLayer2.cornerRadius = 25
      self.maskLayer2.lineWidth = 1.0
      self.maskLayer2.path = bezierPath2.cgPath

      self.previewLayer.addSublayer(self.maskLayer2)
    }
  }

  func makeOverlay4(from observation: VNRectangleObservation) {
    DispatchQueue.main.async {
      let normalized = VNNormalizedRectForImageRect(
        observation.boundingBox, Int(self.previewLayer.frame.width), Int(self.previewLayer.frame.height))

//      let boundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: normalized)
      self.overlayView.layer.borderWidth = 5
      self.overlayView.layer.borderColor = UIColor.green.cgColor
      self.overlayView.bounds = normalized

      debugPrint(normalized)
    }

  }


  func makeOverlay(from observation: VNRectangleObservation) {
    DispatchQueue.main.async {
      let x = self.previewLayer.frame.width * observation.boundingBox.origin.x
      let height = self.previewLayer.frame.height * observation.boundingBox.height
      let y = (self.previewLayer.frame.height) * (observation.boundingBox.origin.y) + 50
      let width = self.previewLayer.frame.width * observation.boundingBox.width


      let bounds = CGRect(
        x: x,
        y: y,
        width: width,
        height: height)

      self.overlayView.frame = bounds
      self.overlayView.layer.borderColor = UIColor.systemTeal.cgColor
      debugPrint(bounds)
    }

  }

  func convert(rect: CGRect) -> CGRect {
    // 1
    let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)

    // 2
    let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)

    // 3
    return CGRect(origin: origin, size: size.cgSize)
  }

  func handleTrackingRequest() {

  }

  func extractPerspectiveRect(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> CIImage {
    // get the pixel buffer into Core Image
    let ciImage = CIImage(cvImageBuffer: buffer)

    // convert corners from normalized image coordinates to pixel coordinates
    let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
    let topRight = observation.topRight.scaled(to: ciImage.extent.size)
    let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
    let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)

    // pass those to the filter to extract/rectify the image
    return ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
      "inputTopLeft": CIVector(cgPoint: topLeft),
      "inputTopRight": CIVector(cgPoint: topRight),
      "inputBottomLeft": CIVector(cgPoint: bottomLeft),
      "inputBottomRight": CIVector(cgPoint: bottomRight),
      ])
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    if segue.identifier == "goToScannedImage",
      let destination = segue.destination as? ScannedImageViewController {
      destination.image = capturedImage
    }
  }


  @IBAction func didTapTakePhoto(_ sender: Any) {
    let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])

    guard let photoOutputConnection = capturePhotoOutput?.connection(with: AVMediaType.video) else {fatalError("Unable to establish input>output connection")}// setup a connection that manages input > output
    
    photoOutputConnection.videoOrientation = .portrait // update photo's output connection to match device's orientation

    let photoSettings = AVCapturePhotoSettings()
    photoSettings.isHighResolutionPhotoEnabled = true
    photoSettings.flashMode = .auto

    capturedRectangleObservation = rectangleLastObservation
    capturePhotoOutput?.capturePhoto(with: settings, delegate: self)

  }

}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension LiveCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_
    output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection) {
    
    handle(buffer: sampleBuffer)
  }

  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let imageData = photo.fileDataRepresentation()
      else { return }

    let image = UIImage(data: imageData)
    self.capturedImage = image

    performSegue(withIdentifier: "goToScannedImage", sender: self)

  }

  func convertFromCamera(_ point: CGPoint) -> CGPoint {

    let orientation = UIDevice.current.orientation

    switch orientation {
    case .portrait:
      return CGPoint(x: point.y * self.previewLayer.frame.width, y: point.x * self.previewLayer.frame.height)
    case .landscapeLeft:
      return CGPoint(x: (1 - point.x) * self.previewLayer.frame.width, y: point.y * self.previewLayer.frame.height)
    case .landscapeRight:
      return CGPoint(x: point.x * self.previewLayer.frame.width, y: (1 - point.y) * self.previewLayer.frame.height)
    case .portraitUpsideDown:
      return CGPoint(x: (1 - point.y) * self.previewLayer.frame.width, y: (1 - point.x) * self.previewLayer.frame.height)
    default:
      return CGPoint(x: point.y * self.previewLayer.frame.width, y: point.x * self.previewLayer.frame.height)
    }
  }

  func crop(within observation: VNRectangleObservation, image: UIImage) -> UIImage {
    let boundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
    let path = CGPath(rect: boundingBoxOnScreen, transform: nil)
    self.maskLayer.path = path

    let x = self.previewLayer.frame.width * observation.boundingBox.origin.x
    let height = self.previewLayer.frame.height * observation.boundingBox.height
    let y = (self.previewLayer.frame.height) * (observation.boundingBox.origin.y) + 50
    let width = self.previewLayer.frame.width * observation.boundingBox.width


    let bounds = CGRect(
      x: x,
      y: y,
      width: width,
      height: height)

    let originalSize: CGSize
    if (image.imageOrientation == .left || image.imageOrientation == .right) {
      originalSize = CGSize(width: image.size.height, height: image.size.width)
    } else {
      originalSize = image.size
    }

    let lastObservationBounds = capturedRectangleObservation?.boundingBox

    let visibleLayerFrame = captureView.bounds
    let metaRect = previewLayer.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame)

    var cropRect = CGRect(x: metaRect.origin.x * originalSize.width, y: metaRect.origin.y * originalSize.height, width: metaRect.size.width * originalSize.width, height: metaRect.size.height * originalSize.height).integral

    if let obs = capturedRectangleObservation {
      cropRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: obs.boundingBox)
    }

    if let finalCGImage = image.cgImage?.cropping(to: bounds) {
      let finImage = UIImage(cgImage: finalCGImage, scale: 1.0, orientation: image.imageOrientation)

      return finImage
//      imageView = UIImageView(image: finImage)
//      self.finalImage = finImage
    }

    return image
  }

  func crop2(within observation: VNRectangleObservation, image: UIImage) -> UIImage {
    let corrected = doPerspectiveCorrection(observation, from: image)
    return corrected
  }

  func doPerspectiveCorrection(_ observation: VNRectangleObservation, from image: UIImage) -> UIImage {

    var ciImage = CIImage(image: image)!

    let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
    let topRight = observation.topRight.scaled(to: ciImage.extent.size)
    let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
    let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)

    ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
      "inputTopLeft": CIVector(cgPoint: topLeft),
      "inputTopRight": CIVector(cgPoint: topRight),
      "inputBottomLeft": CIVector(cgPoint: bottomLeft),
      "inputBottomRight": CIVector(cgPoint: bottomRight),
      ])

    let context = CIContext()
    let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
    let output = UIImage(cgImage: cgImage!)
    return output
  }

}

private extension CGPoint {
  func scaled(to size: CGSize) -> CGPoint {
    return CGPoint(x: self.x * size.width, y: self.y * size.height)
  }
}


extension CGRect {
  var topLeadingPoint: CGPoint { return CGPoint(x: minX, y: minY) }
  var topTrailingPoint: CGPoint { return CGPoint(x: maxX, y: minY) }
  var bottomLeadingPoint: CGPoint { return CGPoint(x: minX, y: maxY) }
  var bottomTrailingPoint: CGPoint { return CGPoint(x: maxX, y: maxY) }
}
