//
//  CGPointExtensions.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
  func scaled(to size: CGSize) -> CGPoint {
    return CGPoint(x: self.x * size.width, y: self.y * size.height)
  }
}
