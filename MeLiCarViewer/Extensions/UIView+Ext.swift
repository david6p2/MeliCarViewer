//
//  UIView+Ext.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/24/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

extension UIView {
  func addSubviews(_ views: UIView...) {
    for view in views {
      addSubview(view)
    }
  }
}
