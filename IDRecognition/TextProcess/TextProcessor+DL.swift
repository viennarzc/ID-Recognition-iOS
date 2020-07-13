//
//  TextProcessor+DriverLicense.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

extension TextProcessor {
  
  /// This is where we modify and insert data for Driver License
  /// - Parameter textModel: array of ScanItem
  func modifyScanItemForDriverLicense(_ textModel: [ScanItem]) -> [ScanItem] {
    let modifiedTextModel = textModel

    //Full name is in a one string
    var fullName: String = ""

    if let row = textModel.firstIndex(where: { $0.name.contains("present_address1") }) {
      let index = processedTexts.getIndex(thatContains: "Address") ?? 0
      let valueIndex = index + 1

      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("government_id") }) {
      let index = processedTexts.getIndex(thatContains: "License No") ?? 0
      let valueIndex = index + 1

      let idNumberString = processedTexts[valueIndex]
      var idNumberCharacters: String = idNumberString
      //get the first 14 characters coz sometimes the string has both the Id number and Date expiration
      if idNumberString.count > 13 {
        let firstCharIndex = idNumberString.index(idNumberString.startIndex, offsetBy: 13)
        idNumberCharacters = String(idNumberString[..<firstCharIndex])
      }

      modifiedTextModel[row].data = idNumberCharacters.trimmedWhiteSpaces()
    }

    guard let nameIndex = processedTexts.getIndex(thatContains: "Last Name") else {
      return modifiedTextModel }

    let valueIndex = nameIndex + 1
    fullName = processedTexts[valueIndex]

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

    if let row = textModel.firstIndex(where: { $0.name.contains("birthday") }) {
      //this id has a format with special character "/"
      let index = processedTexts.getIndex(thatContains: "/") ?? 0
      //drop until 1 or 2, coz birth years starts 1 or 2, ex. 1992, 2001, 2000
      let string = processedTexts[index].dropUntil(character: "1") ?? processedTexts[index].dropUntil(character: "2")
      //count so that we wiil know how many to drop
      let prefixCount = string?.count ?? 0

      let s = processedTexts[index]
      let dateString = String(s.dropFirst(prefixCount))

      if dateString.isValidDate(of: IDDateFormat.umid) {
        modifiedTextModel[row].data =
          formatDate(string: dateString, of: .umid) ?? dateString
      }

    }

    return modifiedTextModel
  }
}
