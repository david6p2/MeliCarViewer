//
//  DataLoader.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit


class DataLoader {
  static let cache = NSCache<NSString, UIImage>()
  
  let baseEndPoint = "https://api.mercadolibre.com/"
  let limit = 10
  let offset = 10
  let searchEndpoint = "sites/MCO/search"
  let defaultSession = URLSession(configuration: .default)
  var dataTask: URLSessionDataTask? = nil
  static let noErrorDescription = "No error Description"
  
  public func searchResultsForCarModel(_ carModel: String?,
                                       withPage page: Int,
                                       handler: @escaping (Result<CarModelResult, DCError>) -> Void) {
    dataTask?.cancel()
    
    var urlComponents = URLComponents(string: baseEndPoint+searchEndpoint )
    let offset = (page - 1) * limit
    var queryParameter = "BRAND=56870"
    if let carModel = carModel, !carModel.isEmpty {
      queryParameter = "MODEL=\(carModel)"
    }
    urlComponents?.query = "category=MCO1744&limit=\(limit)&offset=\(offset)&\(queryParameter)"
    
    guard let url = urlComponents?.url else {
      handler(.failure(DCError(type: .invalidCarModel, errorInfo: "The search URL was not valid. Check your parameters. (\(queryParameter)")))
      return
    }
    
    self.dataTask = defaultSession.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
      defer { self?.dataTask = nil }
      
      if let error = error {
        handler(.failure(DCError(type: .unableToComplete, errorInfo: error.localizedDescription)))
        return
      }
      
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        handler(.failure(DCError(type: .invalidResponse, errorInfo: error?.localizedDescription ?? Self.noErrorDescription)))
        return
      }
      
      guard let data = data else {
        handler(.failure(DCError(type: .invalidData, errorInfo: error?.localizedDescription ?? Self.noErrorDescription)))
        return
      }
      
      do {
        let decodedResponse = try JSONDecoder().decode(CarModelResult.self, from: data)
        handler(.success(decodedResponse))
      } catch {
        let errorDesc = error as NSError
        handler(.failure(DCError(type: .unableToDecode, errorInfo: errorDesc.debugDescription)))
      }
    })
    self.dataTask?.resume()
  }
  
  private func loadCarModelJSON(fileName: String, handler: @escaping (Result<[CarModel], DCError>) -> Void) {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
      do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        var jsonData = try decoder.decode([CarModel].self, from: data)
        jsonData = jsonData.sorted(by: { $0.name < $1.name })
        handler(.success(jsonData))
      } catch {
        let errorDesc = error as NSError
        handler(.failure(DCError(type: .unableToDecode, errorInfo: errorDesc.debugDescription)))
      }
    }
  }
  
  public func getPorscheModels(handler: @escaping (Result<[CarModel], DCError>) -> Void) {
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
  
  public func downloadImage(from urlString: String, handler: @escaping (Result<UIImage, DCError>) -> Void) {
    let cacheKey = NSString(string: urlString)
    if let image = Self.cache.object(forKey: cacheKey) {
      handler(.success(image))
      return
    }
    
    guard let url = URL(string: urlString) else {
      handler(.failure(DCError(type: .unableToComplete, errorInfo: "Can't convert urlString: \(urlString) to a URL")))
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
      if error != nil {
        handler(.failure(DCError(type: .unableToComplete, errorInfo: "Can't download image for: \(urlString) there was an error (\(error.debugDescription))")))
        return
      }
      
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        handler(.failure(DCError(type: .invalidResponse, errorInfo: error.debugDescription)))
        return
      }
      
      guard let data = data else {
        handler(.failure(DCError(type: .invalidData, errorInfo: error.debugDescription)))
        return
      }
      
      guard let image = UIImage(data: data) else {
        handler(.failure(DCError(type: .unableToComplete, errorInfo: error.debugDescription)))
        return
      }
      
      Self.cache.setObject(image, forKey: cacheKey)
      
      DispatchQueue.main.async {
        handler(.success(image))
      }
    }
    task.resume()
  }
}
