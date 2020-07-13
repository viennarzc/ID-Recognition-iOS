//
//  TextProcessor+UMID.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation

extension TextProcessor {
  func modifyScanItemForUMID(_ textModel: [ScanItem]) -> [ScanItem] {
    let modifiedTextModel = textModel

    if let row = textModel.firstIndex(where: { $0.name.contains("government_id") }), let text = processedTexts.first {
      modifiedTextModel[row].data = text
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("last_name") }) {
      let index = processedTexts.getIndex(thatContains: "SURNAME") ?? 0

      //we assume that the next index of SURNAME text is the value, ie. ["SURNAME", "Dela Cruz"]
      let valueIndex = index + 1
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("first_name") }) {
      let index = processedTexts.getIndex(thatContains: "GIVEN NAME") ?? 0


      let valueIndex = index + 1
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("middle_name") }) {
      let index = processedTexts.getIndex(thatContains: "MIDDLE NAME") ?? 0


      let valueIndex = index + 1
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("government_id") }) {
      let index = processedTexts.getIndex(thatContains: "CRN") ?? 0

      let valueIndex = index
      //drop first 4 - which removes - "CRM<space>"
      var droppedFirsts = String(processedTexts[valueIndex].dropFirst(4))

      if droppedFirsts.hasPrefix("-") {
        droppedFirsts = String(droppedFirsts.dropFirst())
      }

      modifiedTextModel[row].data = droppedFirsts
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
