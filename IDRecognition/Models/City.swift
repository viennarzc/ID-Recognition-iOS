//
//  City.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/10/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

struct City: Decodable {
  let name: String


}

struct Cities: Decodable {
  var cities: [City]
}



