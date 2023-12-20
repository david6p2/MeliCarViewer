//
//  CarResultsController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import os.log
import UIKit

class CarResultsController {
    public var porscheModelToSearch: CarModel?
    public var porscheModelsResult: CarModelResult?
    public var carsResults: [CarResult] = []
    var filteredCarsResults: [CarResult] = []

    var page = 1
    var hasMoreResults = true

    private var isFetchInProgress = false
    private var dataLoader: DataLoader

    init(loader: DataLoader = DataLoader(), carModel: CarModel?) {
        dataLoader = loader
        porscheModelToSearch = carModel
    }

    func searchPorscheModel(_ model: String?, page: Int = 1, completion: @escaping (Result<CarModelResult?, DCError>) -> Void) {
        guard !isFetchInProgress else {
            return
        }

        isFetchInProgress = true

        dataLoader.searchResultsForCarModel(model, withPage: page) { [weak self] result in
            switch result {
            case let .success(carModelsResult):
                self?.isFetchInProgress = false
                if carModelsResult.paging.total < carModelsResult.paging.offset + carModelsResult.paging.limit {
                    self?.hasMoreResults = false
                }
                self?.porscheModelsResult = carModelsResult
                self?.carsResults.append(contentsOf: carModelsResult.results)
                completion(.success(self?.porscheModelsResult))
            case let .failure(error):
                self?.isFetchInProgress = false
                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .carResultsController, "%{public}@", errorInfo)
                completion(.failure(error))
            }
        }
    }
}

private extension OSLog {
    static let carResultsController = OSLog.meliCarViewer("carResultsController")
}
