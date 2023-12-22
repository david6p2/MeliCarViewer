//
//  SearchViewViewModel.swift
//  MeLiCarViewer
//
//  Created by Atreyu on 20/12/23.
//  Copyright © 2023 David A Cespedes R. All rights reserved.
//

import Combine
import Foundation
import OSLog

final class SearchViewViewModel {
    var porscheModels: [CarModel]?
    var dataLoader: DataLoader
    lazy var errorPublisher = internalPublisher.eraseToAnyPublisher()
    
    private var internalPublisher: PassthroughSubject<Error, Never>
    private var isFetchInProgress = false

    init(loader: DataLoader = DataLoader()) {
        dataLoader = loader
        internalPublisher = PassthroughSubject()
    }

    func fetchPorscheModels() {
        // Just one request at a time
        guard !isFetchInProgress else {
            return
        }

        isFetchInProgress = true

        dataLoader.getPorscheModels(handler: { [weak self] result in
            switch result {
            case let .success(carModels):
                self?.isFetchInProgress = false
                self?.porscheModels = carModels
            case let .failure(error):
                self?.isFetchInProgress = false
                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .searchViewViewModel, "%{public}@", errorInfo)
                self?.internalPublisher.send(error)
            }
        })
    }
}

// MARK: OSLog

private extension OSLog {
    static let searchViewViewModel = OSLog.meliCarViewer("searchViewViewModel")
}
