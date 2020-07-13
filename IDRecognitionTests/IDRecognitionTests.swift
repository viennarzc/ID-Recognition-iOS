//
//  IDRecognitionTests.swift
//  IDRecognitionTests
//
//  Created by SCI-Viennarz on 6/26/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import XCTest
@testable import IDRecognition

class IDRecognitionTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testParseJson() {


    if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<City>.self, from: data) {
          XCTAssert(!model.isEmpty, "Error Decodcing")

          XCTAssert((model.first(where: { $0.name == "Kidapawan" }) != nil), "Kidapawan Not foudn")
          return
        }

        XCTFail()

      } catch {
        // handle error

        XCTFail()
      }
    }

  }

  func testParseRegions() {
    if let path = Bundle.main.path(forResource: "regions", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<Region>.self, from: data) {
          XCTAssert(!model.isEmpty, "Error Decoding")

          XCTAssert((model.first(where: { $0.longName == "Ilocos Region" }) != nil), "Ilocos Region Not found")
          return
        }

        XCTFail()

      } catch {
        // handle error
        XCTFail()
      }
    }
  }

  func testParseProvinces() {
    if let path = Bundle.main.path(forResource: "provinces", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<Province>.self, from: data) {
          XCTAssert(!model.isEmpty, "Error Decoding")

          XCTAssert((model.first(where: { $0.name == "Benguet" }) != nil), "Benguet Not found")
          return
        }

        XCTFail()

      } catch {
        // handle error
        XCTFail()
      }
    }
    
  }

  func testFindCityInArray() {
    let arrayOfTexts = ["REPUBLIC OF THE PHILIPPINES",
      "DEPARTMENT OF FINANCE",
      "BUREAU OF INTERNAL REVENUE",
      "BUHAYUN, JOHNNY FIED",
      "TIN:",
      "293-201-212-000",
      "Bagol Subd., Sagingun,",
      "Kidapawan City 9400",
      "BIRTH DATE:",
      "05-20-1992",
      "ISSUE DATE:",
      "09-12-2010",
      "SIGNATURE"]

    if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<City>.self, from: data) {
          XCTAssert(!model.isEmpty, "Error Decodcing")

          let j = arrayOfTexts.joined(separator: " ").capitalized

          guard let b = model.first(where: { j.contains($0.name) }) else {
            return XCTFail()

          }

          //check if matches contains
          XCTAssert(!b.name.isEmpty, "\(b.name)")
          return

        }

        XCTFail()

      } catch {
        // handle error

        XCTFail()
      }
    }
  }


}
