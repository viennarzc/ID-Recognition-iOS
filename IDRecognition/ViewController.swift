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

class ViewController: UIViewController {

  private var requests = [VNRequest]()
  private var rectangleLastObservation: VNRectangleObservation?
  private var lastObservation: VNDetectedObjectObservation?
  private var sequenceHandler = VNSequenceRequestHandler()
  private var maskLayer: CAShapeLayer = CAShapeLayer()

  private let session = AVCaptureSession()
  private var previewLayer: AVCaptureVideoPreviewLayer!
  private let queue = DispatchQueue(label: "com.vvc.IDRecognition.vision")

  private var overlayView = UIView()

  private var overlayer = CALayer()


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

      let input = try AVCaptureDeviceInput(device: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!)

      let output = AVCaptureVideoDataOutput()
      output.setSampleBufferDelegate(self, queue: queue)
      previewLayer.videoGravity = .resizeAspectFill

      session.addInput(input)
      session.addOutput(output)
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
      makeOverlay(from: observation)
      self.rectangleLastObservation = observation

    }
  }

  func reqeustHandler(request: VNRequest?, error: Error?) {
    if let error = error {
      print("Error in tracking request \(error.localizedDescription)")
      return
    }


    guard let request = request,
      let results = request.results,
      let ob = results as? [VNRectangleObservation]
      else { return }
  }


  func makeOverlay(from observation: VNRectangleObservation) {
    DispatchQueue.main.async {
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

      self.overlayView.frame = bounds
      self.overlayView.layer.borderColor = UIColor.systemTeal.cgColor

      let points = [observation.topLeft, observation.topRight, observation.bottomRight, observation.bottomLeft]
      let convertedPoints = points.map { self.convertFromCamera($0) }

      let bezierPath = UIBezierPath()
      bezierPath.move(to: .zero)
      bezierPath.addLine(to: convertedPoints[0])
      bezierPath.addLine(to: convertedPoints[1])
      bezierPath.addLine(to: convertedPoints[2])
      bezierPath.addLine(to: convertedPoints[3])
      bezierPath.addLine(to: .zero)

      self.maskLayer.strokeColor = UIColor.blue.cgColor
      self.maskLayer.fillColor = UIColor.clear.cgColor
      self.maskLayer.cornerRadius = 15
      self.maskLayer.lineWidth = 1.0
      self.maskLayer.position = CGPoint(x: 10, y: 10)
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

}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_
    output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection) {

    handle(buffer: sampleBuffer)
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



}



