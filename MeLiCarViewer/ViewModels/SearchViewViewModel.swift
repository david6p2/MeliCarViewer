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
    // @Published var porscheModels: [CarModel]?
    var porscheModels: CurrentValueSubject<[CarModel]?, Error>

    private var isFetchInProgress = false
    var dataLoader: DataLoader

    init(loader: DataLoader = DataLoader()) {
        dataLoader = loader
        porscheModels = CurrentValueSubject(nil)
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
                self?.porscheModels.send(carModels)
            case let .failure(error):
                self?.isFetchInProgress = false
                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .searchViewViewModel, "%{public}@", errorInfo)
                self?.porscheModels.send(completion: .failure(error))
            }
        })
    }
}

private extension OSLog {
    static let searchViewViewModel = OSLog.meliCarViewer("searchViewViewModel")
}

/*
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
 let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
 os_log(.debug, log: .searchController, "%{public}@", errorInfo)
 completion(false)
 break
 }
 })
 }
 }

 extension OSLog {
 fileprivate static let searchController = OSLog.meliCarViewer("searchController")
 }

 */
