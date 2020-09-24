//
//  DCTitleSubtitleAttributeView.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/23/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCTitleSubtitleAttributeView: UIView {

  let attributeTitleLabel = DCSubtitleLabel(textAlignment: .left, fontSize: 10, fontWeight: .medium)
  let attributeValueLabel = DCTitleLabel(textAlignment: .left, fontSize: 12)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configure() {
    attributeTitleLabel.numberOfLines = 0
//    attributeTitleLabel.layer.borderWidth = 1
//    attributeTitleLabel.layer.borderColor = UIColor.blue.cgColor
    attributeValueLabel.numberOfLines = 0
//    attributeValueLabel.layer.borderWidth = 1
//    attributeValueLabel.layer.borderColor = UIColor.red.cgColor
    addSubview(attributeTitleLabel)
    addSubview(attributeValueLabel)
    
    NSLayoutConstraint.activate([
      attributeTitleLabel.topAnchor.constraint(equalTo: self.topAnchor),
      attributeTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      attributeTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      attributeTitleLabel.heightAnchor.constraint(equalToConstant: 12),
      
      attributeValueLabel.topAnchor.constraint(equalTo: attributeTitleLabel.topAnchor, constant: 8),
      attributeValueLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      attributeValueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      attributeValueLabel.heightAnchor.constraint(equalToConstant: 30),
      attributeValueLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 8)
    ])
  }
  
  func setAttribute(title: String, value: String) {
    attributeTitleLabel.text = title
    attributeValueLabel.text = value
  }
}
