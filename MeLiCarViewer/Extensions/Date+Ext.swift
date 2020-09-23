//
//  Date+Ext.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/22/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation

extension Date {
  func convertToDayMonthYearFormat() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: self)
  }
}
