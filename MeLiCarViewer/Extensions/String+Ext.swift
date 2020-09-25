//
//  String+Ext.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/22/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation

extension String {
  func convertToDate() -> Date? {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormater.locale = Locale(identifier: "es_CO")
    dateFormater.timeZone = .current

    return dateFormater.date(from: self)
  }

  func convertToDisplayFormat() -> String {
    guard let date = convertToDate() else { return "N/A" }
    return date.convertToDayMonthYearFormat() 
  }
}
