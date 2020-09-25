//
//  DCAlertContainerView.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/24/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCAlertContainerView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configure() {
    backgroundColor = .systemBackground
    layer.cornerRadius = 16
    layer.borderWidth = 2
    layer.borderColor = UIColor.white.cgColor
    translatesAutoresizingMaskIntoConstraints = false
  }
}
