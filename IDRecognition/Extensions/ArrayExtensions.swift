//
//  ArrayExtensions.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

extension Array where Element == String {
  func removeUnnecessaryWords(for type: TextProcessor.ID) -> [String] {
    //TODO: create constant array of removables of each id type
    switch type {
    case .driversLicense:
      return self.filter {
        !$0.contains("Driver's") &&
          !$0.contains("LAND TRANSPORTATION") &&
          !$0.contains("REPUBLIC") &&
          !$0.contains("DEPARTMENT") &&
          !$0.contains("TRANSPORTATION OFFICE") &&
          !$0.contains("Signature of Licensee") &&
          !$0.contains("Land Transportaion") &&
          !$0.contains("Assistant Secretary") &&
          !$0.contains("Blood Type") &&
          !$0.contains("Eyes Color") &&
          !$0.contains("Restrictions") &&
          !$0.contains("Conditions") &&
          !$0.contains("GALVANTE") &&
          !$0.contains("Sex") &&
          !$0.contains("Date") &&
          !$0.contains("Agency") &&
          !$0.contains("Weight") &&
          !$0.contains("Height") &&
          !$0.contains("LICENSE") &&
          !$0.contains("Nationality") &&
          ($0.count > 2)
      }

    case .tin:
      return self.filter {
        !$0.contains("DEPARTMENT") &&
          !$0.contains("REPUBLIC") &&
          !$0.contains("BUREAU") &&
          !$0.contains("INTERNAL REVENUE") &&
          !$0.contains("INTERNAL") &&
          !$0.contains("REVENUE") &&
          !$0.contains("PHILIPPINES") &&
          !$0.contains("THE") &&
          !$0.contains("SIGNATURE")
      }
    case .umid:
      return self.filter { !$0.contains("REPUBLIC") && !$0.contains("Unified Multi-Purpose ID") }

    case .passport:
      return self.filter {
        !$0.contains("REPUBLIKA NG PILIPINAS") &&
          !$0.contains("PASAPORTE") &&
          !$0.contains("REPUBLIC") &&
          !$0.contains("REPUBLIKA") &&
          !$0.contains("Uni") &&
          !$0.contains("Pasaporte") &&
          !$0.contains("Kodigo") &&
          !$0.contains("<<<<") &&
          !$0.contains("Makakalikasan") &&
          !$0.contains("Maka-Tao") &&
          !$0.contains("Makabansa") &&
          !$0.contains("<<<<") &&
          !$0.contains("f") &&
          !$0.contains("Uri") &&
          !$0.contains("f") &&
          !$0.contains("i") &&
          !$0.contains("Maka-Diyos")

      }
    }
  }

  func removeUMID_CRNStringIfNeeded() -> [String] {
    return self.map { (text) -> String in
      if text.contains("CRN") {
        return String(text.dropFirst(4))
      }

      return text
    }

  }

  func getIndex(thatContains text: String) -> Array<Element>.Index? {
    guard let index = self.firstIndex(where: { $0.contains(text) })
      else { return nil }

    return index
  }

}

