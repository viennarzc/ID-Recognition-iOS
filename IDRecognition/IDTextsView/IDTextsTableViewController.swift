//
//  IDTextsTableViewController.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import UIKit

class IDTextsTableViewController: UITableViewController {
  var viewModel: IDTextsTableViewModel? {
    didSet {
      tableView.reloadData()
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let vm = viewModel else { return 0 }
    return vm.items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
      return UITableViewCell()
    }
    
    if let vm = viewModel {
      cell.textLabel?.adjustsFontSizeToFitWidth = true
      cell.textLabel?.text = vm.items[indexPath.row].labelText
    }
    
    return cell
  }
}

struct IDTextsTableViewModel {
  var items: [ScanItem] = []
  
  init(texts: [String]) {
    let types = [
      KYCType(name: "first_name", data: ""),
      KYCType(name: "last_name", data: ""),
      KYCType(name: "middle_name", data: ""),
      KYCType(name: "birthday", data: ""),
      KYCType(name: "city_of_birth", data: ""),
      KYCType(name: "nationality", data: ""),
      KYCType(name: "country_of_birth", data: ""),
      KYCType(name: "source_of_income", data: ""),
      KYCType(name: "nature_of_work", data: ""),
      KYCType(name: "present_address1", data: ""),
      KYCType(name: "present_address2", data: ""),
      KYCType(name: "present_city", data: ""),
      KYCType(name: "present_province", data: ""),
      KYCType(name: "present_country", data: ""),
      KYCType(name: "present_postal_code", data: ""),
      KYCType(name: "permanent_address1", data: ""),
      KYCType(name: "permanent_address2", data: ""),
      KYCType(name: "permanent_city", data: ""),
      KYCType(name: "permanent_province", data: ""),
      KYCType(name: "permanent_country", data: ""),
      KYCType(name: "permanent_postal_code", data: ""),
      KYCType(name: "gov_id1_type", data: ""),
      KYCType(name: "government_id1", data: ""),
      
    ]
    
    self.items = TextProcessor.shared.process(texts: texts, createModelsFrom: types)
  }
}


class ScanItem {
  var name: String = ""
  var data: String = ""
  
  var labelText: String {
    "\(name): \(data)"
  }
  
  init(name: String, data: String) {
    self.name = name
    self.data = data
  }
}

