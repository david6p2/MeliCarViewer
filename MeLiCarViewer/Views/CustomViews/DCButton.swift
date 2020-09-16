//
//  DCButton.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCButton: UIButton {

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  init(backgroundColor: UIColor, title: String) {
    super.init(frame: .zero)
    self.backgroundColor = backgroundColor
    self.setTitle(title, for: .normal)
    configure()
  }
  
  private func configure() {
    layer.cornerRadius = 10
    setTitleColor(.white, for: .normal)
    titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    translatesAutoresizingMaskIntoConstraints = false
    
  }
}
