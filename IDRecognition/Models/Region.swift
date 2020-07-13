//
//  Region.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/13/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

struct Region: Decodable {
  let name: String
  let longName: String
  let key: String
  
  enum CodingKeys: String, CodingKey {
    case name
    case longName = "long"
    case key
    
  }
}
