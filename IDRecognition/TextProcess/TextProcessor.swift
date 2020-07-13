//
//  TextProcessor.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation
import NaturalLanguage
import Vision

final class TextProcessor {
  public static let shared = TextProcessor()

  private(set) var processedTexts: [String] = []

  /// Government ID Types, will add more in the future
  enum ID {
    case umid
    case driversLicense
    case tin
    case passport
  }

  struct IDDateFormat {
    static let umid = "yyyy/MM/dd"
    static let driversLicense = "yyyy/MM/dd"
    static let tin = "MM-dd-yyyy"
    static let passport = "dd MMMM yyyy"
  }

  /// Process the scanned texts using Camera
  /// - Parameters:
  ///   - texts: Scanned texts using the camera - MLKit or VNRecognizeTextRequest
  ///   - types: kyc types from the Backend - Identity Service
  func process(texts: [String], createModelsFrom types: [KYCType]) -> [ScanItem] {
    var models: [ScanItem] = []

    switch identifyIdType(from: texts) {

    case .driversLicense:
      self.processedTexts = texts.removeUnnecessaryWords(for: .driversLicense)
      models = createModel(fromKyc: types)

      return modifyScanItemForDriverLicense(models)

    case .tin:
      self.processedTexts = texts.removeUnnecessaryWords(for: .tin)
      models = createModel(fromKyc: types)

      return modifyScanItemForTIN(models)

    case .umid:
      self.processedTexts = texts.removeUnnecessaryWords(for: .umid)
      models = createModel(fromKyc: types)

      return modifyScanItemForUMID(models)

    case .passport:
      self.processedTexts = texts.removeUnnecessaryWords(for: .passport)
      models = createModel(fromKyc: types)

      return modifyScanItemForPassport(models)

    case .none:
      break
    }

    return models
  }

  /// Create model from KYCType
  /// - Parameter types: kyc types from Backend API
  private func createModel(fromKyc types: [KYCType]) -> [ScanItem] {
    return types.map { ScanItem(name: $0.name, data: "") }
  }

  

  private func modifyScanItemForPassport(_ textModel: [ScanItem]) -> [ScanItem] {
    var modifiedTextModel = textModel

    if let row = textModel.firstIndex(where: { $0.name.contains("last_name") }) {
      let index = processedTexts.getIndex(thatContains: "Apelyido") ?? 0

      //we assume that the next index of SURNAME text is the value, ie. ["SURNAME", "Dela Cruz"]
      let valueIndex = index + 1
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("middle_name") }) {
      let index = processedTexts.getIndex(thatContains: "Petsa ng kapanganakan") ?? processedTexts.getIndex(thatContains: "Date of birth") ?? 0

      //we assume that the next index of SURNAME text is the value, ie. ["SURNAME", "Dela Cruz"]
      let valueIndex = (index == 0) ? 0 : (index - 1)
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("first_name") }) {
      let index = processedTexts.getIndex(thatContains: "Pangalan") ?? processedTexts.getIndex(thatContains: "Given names") ?? 0

      //we assume that the next index of SURNAME text is the value, ie. ["SURNAME", "Dela Cruz"]
      let valueIndex = index + 1
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("government_id") }) {
      let index = processedTexts.getIndex(thatContains: "PHL") ?? 0

      let valueIndex = index + 1
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }

    if let row = textModel.firstIndex(where: { $0.name.contains("birthday") }) {
      let index = processedTexts.getIndex(thatContains: "Date of birth") ?? processedTexts.getIndex(thatContains: "Petsa ng kapanganakan") ?? 0

      let valueIndex = index + 1

      modifiedTextModel[row].data =
        formatDate(string: processedTexts[valueIndex], of: .passport) ?? processedTexts[valueIndex]

    }

    if let row = textModel.firstIndex(where: { $0.name.contains("nationality") }) {
      let index = processedTexts.getIndex(thatContains: "Nasyonalidad") ?? processedTexts.getIndex(thatContains: "nationality") ?? 0

      let valueIndex = index + 1

      modifiedTextModel[row].data =
        formatDate(string: processedTexts[valueIndex], of: .passport) ?? processedTexts[valueIndex]

    }

    if let row = textModel.firstIndex(where: { $0.name.contains("city_of_birth") }) {
      let index = processedTexts.getIndex(thatContains: "Petsa ng pagkakaloob") ?? processedTexts.getIndex(thatContains: "Date of issue") ?? 0

      let valueIndex = (index == 0) ? 0 : (index - 1)
      modifiedTextModel[row].data = processedTexts[valueIndex]
    }


    return modifiedTextModel
  }

  private func identifyIdType(from texts: [String]) -> TextProcessor.ID? {
    if texts.contains(where: { $0.contains("Unified Multi-Purpose ID") }) {
      return .umid

    } else if texts.contains(where: { $0.contains("DRIVER'S LICENSE") }) {
      return .driversLicense

    } else if texts.contains(where: {
      $0.contains("DEPARTMENT OF FINANCE") ||
        $0.contains("INTERNAL REVENUE") }) {
      return .tin

    } else if texts.contains(where: {
      $0.contains("PASSPORT") ||
        $0.contains("PASAPORTE") }) {

      return .passport
    }

    return nil

  }

  //ids have different birthday format
  func formatDate(string: String, of id: ID) -> String? {
    var dateFormat: String = "MM-dd-yyyy"
    switch id {

    case .umid:
      dateFormat = "yyyy/MM/dd"
    case .driversLicense:
      dateFormat = "yyyy/MM/dd"
    case .tin:
      dateFormat = "MM-dd-yyyy"
    case .passport:
      dateFormat = "dd MMMM yyyy"
      @unknown default:
      break
    }

    //formats in iSO8601
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.dateFormat = dateFormat

    //formats for birthdate format to be submission ready for backend server
    let dd = formatter.date(from: string)
    return string
  }
}
