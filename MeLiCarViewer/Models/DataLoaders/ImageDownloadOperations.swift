//
//  ImageDownloadOperations.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/21/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class PendingOperations {
  lazy var downloadsInProgress: [String: Operation] = [:]
  lazy var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "DownloadQueue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
}

class ImageDownloader: Operation {
  var picture: Picture
  var image: UIImage = Images.placeholder!
  
  init(_ picture: Picture) {
    self.picture = picture
  }
  
  override func main() {
    if isCancelled {
      return
    }
    
    guard let secureUrl =  URL(string: picture.secureUrl),
      let imageData = try? Data(contentsOf: secureUrl) else {
        return
    }
    
    if isCancelled {
      return
    }
    
    if !imageData.isEmpty, let image = UIImage(data: imageData) {
      self.image = image
    } else {
      self.image = Images.placeholder!
    }
    
  }
}
