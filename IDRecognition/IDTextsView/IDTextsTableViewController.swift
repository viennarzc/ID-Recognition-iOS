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
      cell.textLabel?.text = vm.items[indexPath.row].labelText
    }
    
    return cell
  }
}

struct IDTextsTableViewModel {
  var items: [ScanItem] = []
  
  init() {
    
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

