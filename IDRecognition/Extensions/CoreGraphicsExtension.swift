//
//  CoreGraphicsExtension.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 6/26/20.
//  Copyright © 2020 VVC. All rights reserved.
//


import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x * right, y: left.y * right)
}

extension CGSize {
  var cgPoint: CGPoint {
    return CGPoint(x: width, y: height)
  }
}

extension CGPoint {
  var cgSize: CGSize {
    return CGSize(width: x, height: y)
  }
  
  func absolutePoint(in rect: CGRect) -> CGPoint {
    return CGPoint(x: x * rect.size.width, y: y * rect.size.height) + rect.origin
  }
}
