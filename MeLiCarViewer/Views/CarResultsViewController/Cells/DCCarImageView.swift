//
//  DCCarImageView.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/15/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCCarImageView: UIImageView {
  
  var dataLoader = DataLoader()

  let placeholderImage = UIImage(named: "CarPlaceholder")
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  private func configure() {
    layer.cornerRadius = 10
    clipsToBounds = true
    image = placeholderImage
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setImage(from urlString: String) {
    dataLoader.downloadImage(from: urlString) { [weak self] (result) in
      guard let self = self else {
        return
      }
      switch result {
      case .success(let image):
        self.image = image
      case .failure(let error):
        print(error.errorInfo ?? DataLoader.noErrorDescription)
      }
    }
  }

}
