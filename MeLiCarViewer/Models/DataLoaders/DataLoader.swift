//
//  DataLoader.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

/// This class manage all the network requests
class DataLoader {
  static let cache = NSCache<NSString, UIImage>()

  static let porscheModelsFilename = "PorscheModels"
  
  let baseEndPoint = "https://api.mercadolibre.com/"
  let limit = 10
  let offset = 10
  let searchEndpoint = "sites/MCO/search"
  let pictureDetailsEndpoint = "items/"
  let defaultSession = URLSession(configuration: .default)
  var dataTask: URLSessionDataTask? = nil
  static let noErrorDescription = "No error Description"
  
  /// Create a Request to GET the search results of Porsche Cars giving a Model. If  no model is given, it will return all Porsche cars available.
  /// - Parameters:
  ///   - carModel: The model id code of the porsche car for the MCO site in Mercado Libre
  ///   - page: the page results you want to bring. By default it will bring just 10 results.
  ///   - handler: Will return a completion closure with the result having the CarModelResult if it succed or the Error if it fails
  public func searchResultsForCarModel(_ carModel: String?,
                                       withPage page: Int,
                                       handler: @escaping (Result<CarModelResult, DCError>) -> Void) {
    dataTask?.cancel()
    
    var urlComponents = URLComponents(string: baseEndPoint+searchEndpoint )
    let offset = (page - 1) * limit
    var queryParameter = "BRAND=56870" // The Brand ID for Porsche
    if let carModel = carModel, !carModel.isEmpty {
      queryParameter = "MODEL=\(carModel)"
    }
    urlComponents?.query = "category=MCO1744&limit=\(limit)&offset=\(offset)&\(queryParameter)"
    
    guard let url = urlComponents?.url else {
      handler(.failure(DCError(type: .invalidCarModel, errorInfo: "The search URL was not valid. Check your parameters. (\(queryParameter)")))
      return
    }
    
    dataTask = defaultSession.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
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
    dataTask?.resume()
  }
  
  /// Create a Request to GET  all the detail information of a given car Id, including the pictures
  /// - Parameters:
  ///   - carId: Item id (the car id in this case). Ex MCO578263412
  ///   - handler: Will return a handler closure with the result having the CarPicturesInformation if it succed or the Error if it fails
  public func loadCarPicturesInformation(withCarId carId: String, handler: @escaping (Result<CarPicturesInformation, DCError>) -> Void) {
    dataTask?.cancel()
    
    let urlComponents = URLComponents(string: baseEndPoint + pictureDetailsEndpoint + carId)
    
    guard let url = urlComponents?.url else {
      handler(.failure(DCError(type: .invalidCarModel, errorInfo: "The search URL was not valid. Check your URL. (\(urlComponents ?? URLComponents(string:"N/A")!)")))
      return
    }
    
    dataTask = defaultSession.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
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
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decodedResponse = try decoder.decode(CarPicturesInformation.self, from: data)
        handler(.success(decodedResponse))
      } catch {
        let errorDesc = error as NSError
        handler(.failure(DCError(type: .unableToDecode, errorInfo: errorDesc.debugDescription)))
      }
    })
    dataTask?.resume()
  }

  /// Load the car Models from a JSON file
  /// - Parameters:
  ///   - fileName: The filename of the JSON where the car models are stored
  ///   - handler: Will return a handler closure with the result having the CarModels in an array if it succed or the Error if it fails
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

  /// Call to get the Porsche Models from a JSON file called "PorscheModels"
  /// - Parameter handler: Will return a handler closure with the result having the CarModels result in an array if it succed or the Error if it fails
  public func getPorscheModels(handler: @escaping (Result<[CarModel], DCError>) -> Void) {
    // Loading from JSON File
    loadCarModelJSON(fileName: Self.porscheModelsFilename) { (result) in
      switch result {
      case .success(let carModels):
        handler(.success(carModels))
      case .failure(let error):
        handler(.failure(error))
      }
    }
  }

  /// Create a Request to GET an image from the passed urlString
  /// - Parameters:
  ///   - urlString: The URL String of the image
  ///   - handler: Will return a handler closure with the result having the requested UIImage if it succed or the Error if it fails
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
