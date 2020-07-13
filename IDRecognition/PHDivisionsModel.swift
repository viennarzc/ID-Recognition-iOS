//
//  PHDivisionsModel.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/13/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation


final class PHDivisionsModel {
  public static let shared = PHDivisionsModel()

  var cities: [City] = []
  var regions: [Region] = []
  var provinces: [Province] = []

  init() {

  }

  func loadCities() {

    if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<City>.self, from: data) {
          self.cities = model
        }

      } catch {
        // handle error
      }
    }
  }

  func loadRegions() {
    if let path = Bundle.main.path(forResource: "regions", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<Region>.self, from: data) {
          self.regions = model
        }

      } catch {
        // handle error
      }
    }

  }

  func loadProvinces() {
    if let path = Bundle.main.path(forResource: "provinces", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let decoder = JSONDecoder()

        if let model = try? decoder.decode(Array<Province>.self, from: data) {
          self.provinces = model
        }

      } catch {
        // handle error
      }
    }
  }
  
  func findCity(from: String, completion: @escaping (City?) -> Void) {
    guard let city = cities.first(where: { from.capitalized.contains($0.name.capitalized) }) else {
      return completion(nil)}
    
    completion(city)
    
  }
  
  func findProvince(from: String, completion: @escaping (Province?) -> Void) {
    guard let province = provinces.first(where: { from.capitalized.contains($0.name.capitalized) }) else {
      return completion(nil)}
    
    completion(province)
    
  }


}
