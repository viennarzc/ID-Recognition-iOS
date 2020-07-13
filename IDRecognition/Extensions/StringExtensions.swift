//
//  StringExtensions.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

//MARK: - Extension String


extension String {
  func isValidDate(of dateFormat: String) -> Bool {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = dateFormat
    return dateFormatterGet.date(from: self) != nil
  }

  func dropUntil(character: String) -> String? {
    if let index = self.range(of: character)?.lowerBound {
      let substring = self[..<index]
      // (see picture below) Using the prefix(upTo:) method is equivalent to using a partial half-open range as the collection’s subscript.
      // The subscript notation is preferred over prefix(upTo:).

      let string = String(substring)
      return string
    }

    return self
  }
  
  func trimmedWhiteSpaces() -> String {
    return trimmingCharacters(in: CharacterSet.whitespaces)
  }

}
