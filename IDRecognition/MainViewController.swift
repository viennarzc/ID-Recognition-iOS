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
    PHDivisionsModel.shared.loadProvinces()
    PHDivisionsModel.shared.loadCities()

  }




}
