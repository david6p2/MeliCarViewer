//
//  CarResultsViewModel.swift
//  MeLiCarViewer
//
//  Created by David on 8/01/24.
//  Copyright © 2024 David A Cespedes R. All rights reserved.
//

import Foundation
import os.log
import RxSwift
import RxCocoa

final class CarResultsViewModel {
    
    // MARK: - Properties
    
    public var porscheModelToSearch: CarModel?
    public var carsResults: [CarResult] = []
    var filteredCarsResults: [CarResult] = []
    
    var page = 1
    var hasMoreResults = true

    private var isFetchInProgress = false
    private var dataLoader: DataLoader
    
    // MARK: - Rx Properties
    
    var porscheModelsResultDriver: Driver<Result<CarModelResult?, DCError>> {
        porscheModelsResultRelay.asDriver()
    }
    private let porscheModelsResultRelay = BehaviorRelay<Result<CarModelResult?, DCError>>(value: .success(nil))
    
    var isFetchInProgressDriver: Driver<Bool> {
        isFetchInProgressRelay.asDriver()
    }
    private let isFetchInProgressRelay = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(loader: DataLoader = DataLoader(), carModel: CarModel?) {
        dataLoader = loader
        porscheModelToSearch = carModel
    }
    
    func searchPorscheModel(page: Int = 1) {
        guard !isFetchInProgress else {
            return
        }

        isFetchInProgress = true

        dataLoader.searchResultsForCarModel(porscheModelToSearch?.id, withPage: page) { [weak self] result in
            switch result {
            case let .success(carModelsResult):
                self?.isFetchInProgress = false
                if carModelsResult.paging.total < carModelsResult.paging.offset + carModelsResult.paging.limit {
                    self?.hasMoreResults = false
                }
                self?.carsResults.append(contentsOf: carModelsResult.results)
                self?.porscheModelsResultRelay.accept(.success(carModelsResult))
            case let .failure(error):
                self?.isFetchInProgress = false
                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .carResultsViewModel, "%{public}@", errorInfo)
                self?.porscheModelsResultRelay.accept(.failure(error))
            }
        }
    }
}

private extension OSLog {
    static let carResultsViewModel = OSLog.meliCarViewer("carResultsViewModel")
}
