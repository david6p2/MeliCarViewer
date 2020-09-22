//
//  CarResultsController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation
import UIKit

class CarResultsController {
  public var porscheModelToSearch: CarModel?
  public var porscheModelsResult: CarModelResult? = nil
  
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
        completion(.success(self?.porscheModelsResult))
        break
      case .failure(let error):
        self?.isFetchInProgress = false
        print(error.errorInfo ?? DataLoader.noErrorDescription)
        completion(.failure(error))
        break
      }
    }
  }
  
}
