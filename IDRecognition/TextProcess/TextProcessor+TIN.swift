//
//  TextProcess+TIN.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

extension TextProcessor {
  func modifyScanItemForTIN(_ textModel: [ScanItem]) -> [ScanItem] {
    let modifiedTextModel = textModel

    if let row = textModel.firstIndex(where: { $0.name.contains("government_id") }) {
      let index = processedTexts.getIndex(thatContains: "TIN") ?? 2
      let valueIndex = index + 1

      let idNumberString = processedTexts[valueIndex]
      //get the first 14 characters coz sometimes the string has both the Id number and Date expiration
      modifiedTextModel[row].data = idNumberString.trimmedWhiteSpaces()
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("present_address1") }) {
      let index = processedTexts.getIndex(thatContains: "TIN") ?? 3
      let valueIndex = index + 2

      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("birthday") }),
      let index = processedTexts.getIndex(thatContains: "BIRTH DATE") {

      let valueIndex = index + 1


      modifiedTextModel[row].data =
        formatDate(string: processedTexts[valueIndex], of: .tin) ?? processedTexts[valueIndex]
    }

    guard let fullName = processedTexts.first else { return modifiedTextModel }

    //Driver's License format in name is 'Last Name, First Name. Middle Name'
    if let row = textModel.firstIndex(where: { $0.name.contains("last_name") }) {
      //we assume that the next index of Middle Name text is the full name in ID, ie. ["Middle Name", "Dela Cruz, Juan Ponce"]

      if let lastNameString = fullName.components(separatedBy: ",").first {
        modifiedTextModel[row].data = String(lastNameString).trimmedWhiteSpaces()
      }

    }

    if let row = textModel.firstIndex(where: { $0.name.contains("middle_name") }) {
      //we assume that the next index of Middle Name text is the full name in ID, ie. ["Middle Name", "Dela Cruz, Juan Ponce"]
      if let firstMiddle = fullName.components(separatedBy: ",").last,
        let mid = firstMiddle.components(separatedBy: " ").last {
        modifiedTextModel[row].data = mid.trimmedWhiteSpaces()
      }

    }

    if let row = textModel.firstIndex(where: { $0.name.contains("first_name") }) {
      //we assume that the next index of Middle Name text is the full name in ID, ie. ["Middle Name", "Dela Cruz, Juan Ponce"]
      if let firstMiddle = fullName.components(separatedBy: ",").last,
        let first = firstMiddle.trimmedWhiteSpaces().components(separatedBy: " ").first {
        modifiedTextModel[row].data = first.trimmedWhiteSpaces()
      }

    }

    return modifiedTextModel
  }

}
