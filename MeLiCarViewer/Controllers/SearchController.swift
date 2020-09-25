//
//  SearchController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation

class SearchController {
  public var porscheModels: [CarModel]? = .init()

  private var isFetchInProgress = false
  var dataLoader: DataLoader

  init(loader: DataLoader = DataLoader()) {
    self.dataLoader = loader
  }

  func fetchPorscheModels(_ completion: @escaping (_ success: Bool) -> Void) {
    // Just one request at a time
    guard !isFetchInProgress else {
      return
    }

    isFetchInProgress = true

    dataLoader.getPorscheModels(handler: { [weak self] (result) in
      guard let self = self else {
        completion(false)
        return
      }

      switch result {
      case .success(let carModels):
        self.isFetchInProgress = false
        self.porscheModels = carModels
        completion(true)
        break
      case .failure(let error):
        self.isFetchInProgress = false
        print(error.errorInfo ?? DataLoader.noErrorDescription)
        completion(false)
        break
      }
    })
  }
}
