//
//  CarResultsController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit
import os.log

class CarResultsController {
  public var porscheModelToSearch: CarModel?
  public var porscheModelsResult: CarModelResult? = nil
  public var carsResults: [CarResult] = []
  var filteredCarsResults: [CarResult] = []

  var page = 1
  var hasMoreResults = true

  private var isFetchInProgress = false
  private var dataLoader: DataLoader

  init(loader: DataLoader = DataLoader(), carModel: CarModel?) {
    self.dataLoader = loader
    self.porscheModelToSearch = carModel
  }

  func searchPorscheModel(_ model: String?, page: Int = 1, completion: @escaping (Result<CarModelResult?, DCError>) -> Void) {
    guard !isFetchInProgress else {
      return
    }

    isFetchInProgress = true

    dataLoader.searchResultsForCarModel(model, withPage: page) { [weak self] (result) in
      switch result {
      case .success(let carModelsResult):
        self?.isFetchInProgress = false
        if carModelsResult.paging.total < carModelsResult.paging.offset + carModelsResult.paging.limit {
          self?.hasMoreResults = false
        }
        self?.porscheModelsResult = carModelsResult
        self?.carsResults.append(contentsOf: carModelsResult.results)
        completion(.success(self?.porscheModelsResult))
        break
      case .failure(let error):
        self?.isFetchInProgress = false
        let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
        os_log(.debug, log: .carResultsController, "%{public}@", errorInfo)
        completion(.failure(error))
        break
      }
    }
  }
}

extension OSLog {
  fileprivate static let carResultsController = OSLog.meliCarViewer("carResultsController")
}
