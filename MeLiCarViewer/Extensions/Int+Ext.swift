//
//  Int+Ext.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/22/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation

extension Int {
  func convertToPriceInCOP() -> String? {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale(identifier: "es_CO")
    
    return currencyFormatter.string(from: NSNumber(value: self))
  }
}
