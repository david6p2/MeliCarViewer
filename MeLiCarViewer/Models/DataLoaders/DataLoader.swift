//
//  DataLoader.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation


struct DataLoader {
  private func loadCarModelJSON(fileName: String, handler: @escaping (Result<[CarModel], Error>) -> Void) {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
      do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        var jsonData = try decoder.decode([CarModel].self, from: data)
        jsonData = jsonData.sorted(by: { $0.name < $1.name })
        handler(.success(jsonData))
      } catch {
        handler(.failure(error))
      }
    }
  }
  
  public func getPorscheModels(handler: @escaping (Result<[CarModel], Error>) -> Void) {
    // Loading from JSON File
    self.loadCarModelJSON(fileName: "PorscheModels") { (result) in
      switch result {
      case .success(let carModels):
        handler(.success(carModels))
      case .failure(let error):
        handler(.failure(error))
      }
    }
  }
}
