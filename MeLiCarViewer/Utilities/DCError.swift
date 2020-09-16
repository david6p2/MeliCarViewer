//
//  DCError.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/15/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation

struct DCError: Error {
  let type: ErrorType
  let errorInfo: String?
}

enum ErrorType: String {
  case invalidCarModel
  case unableToComplete
  case invalidResponse
  case invalidData
  case unableToDecode
}
