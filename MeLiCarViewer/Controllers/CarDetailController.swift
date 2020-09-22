//
//  CarDetailController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/21/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarDetailController {
  public var porscheResult: CarResult!
  public var porschePicturesInformation: CarPicturesInformation?
  
  private var isFetchInProgress = false
  private var dataLoader: DataLoader
  
  private let pendingOperations = PendingOperations()
  
  init(loader: DataLoader = DataLoader(), porscheResult: CarResult?) {
    self.dataLoader = loader
    self.porscheResult = porscheResult
  }
  
  func searchPorschePictures(forPorscheId carId: String, completion: @escaping (Result<[Picture], DCError>) -> Void) {
    guard !isFetchInProgress else {
      return
    }
    
    isFetchInProgress = true
    
    dataLoader.loadCarPicturesInformation(withCarId: carId) { [weak self] (result) in
      guard let self = self else { return }
      switch result {
      case .success(let carPicturesInformation):
        self.isFetchInProgress = false
        self.porschePicturesInformation = carPicturesInformation
        if let pictures = self.porschePicturesInformation?.pictures {
          completion(.success(pictures))
        } else {
          completion(.failure(DCError(type: .unableToComplete, errorInfo: "There where no pictures in the porschePicturesInformation Model. Confirm porschePicturesInformation is not nil.")))
        }
        break
      case . failure(let error):
        self.isFetchInProgress = false
        print(error.errorInfo ?? DataLoader.noErrorDescription)
        completion(.failure(error))
        break
      }
    }
  }
  
  func startDownload(for carPictures: [Picture], completion: @escaping () -> Void) {
    for (index, picture) in carPictures.enumerated() {
      guard pendingOperations.downloadsInProgress[picture.id] == nil else {
        return
      }
      
      let downloader = ImageDownloader(picture)
      
      downloader.completionBlock = { [weak self] in
        guard let self = self else { return }
        
        if downloader.isCancelled {
          return
        }
        
        DispatchQueue.main.async {
          if self.porschePicturesInformation?.images == nil {
            self.porschePicturesInformation?.images = []
          }
          self.porschePicturesInformation?.images?.insert(downloader.image.pngData()!, at: index)
          self.pendingOperations.downloadsInProgress.removeValue(forKey: picture.id)
          if index == carPictures.count-1 {
            completion()
          }
        }
      }
      
      pendingOperations.downloadsInProgress[picture.id] = downloader
      pendingOperations.downloadQueue.addOperation(downloader)
    }
  }
}
