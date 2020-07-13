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
    } }


}
