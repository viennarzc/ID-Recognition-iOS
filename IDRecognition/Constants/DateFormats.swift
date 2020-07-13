//
//  DateFormats.swift
//  IDRecognition
//
//  Created by SCI-Viennarz on 7/8/20.
//  Copyright © 2020 VVC. All rights reserved.
//

import Foundation
struct DateFormat {
  static let birthdate = "yyyy-MM-dd"
  static let governmentID = "yyyy-MM-dd"
  static let datePicker = "MMM d, yyyy"
  static let short = "MMM d"
  ///**format** - MMMM d, Y
  static let readableByHuman = DateFormat.gregorianMDY
  static let readableByHumanShort = DateFormat.datePicker
  static let gregorianMDY = "MMMM d, Y"
  static let timeOfDay = "hh:mm a"
  static let readableDateAndTime = "MMMM d, Y hh:mm a"
  static let readableExpirationDate = "MMMM dd, yyyy"
  
  static let calendarFormat = "yyyy-MM-dd"
  static let monthFormat = "MMMM"
  static let yearFormat = "yyyy"
  static let scheduleFormat = "MMMM dd, yyyy"
  
  static let monthYearFormat = "MMMM yyyy"
  static let iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
}
