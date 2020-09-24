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
  
  convenience init(_ cornerRadius: CGFloat) {
    self.init(frame:.zero)
    configure(cornerRadius)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  private func configure(_ cornerRadius: CGFloat = 10) {
    layer.cornerRadius = cornerRadius
    clipsToBounds = true
    image = placeholderImage
    contentMode = .scaleAspectFill
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setImage(from urlString: String) {
    dataLoader.downloadImage(from: urlString) { [weak self] (result) in
      guard let self = self else {
        return
      }
      switch result {
      case .success(let image):
        DispatchQueue.main.async { self.image = image }
      case .failure(let error):
        print(error.errorInfo ?? DataLoader.noErrorDescription)
      }
    }
  }

}
