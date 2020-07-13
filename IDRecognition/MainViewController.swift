//
//  MainViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/2/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.


    if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<City>.self, from: data) {
          print(model)
        }

      } catch {
        // handle error
      }
    }
  }
}
