//
//  UIHelper.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/17/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

struct UIHelper {
  static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
    let width = view.bounds.width
    let padding: CGFloat = 12
    let minimumItemSpacing: CGFloat = 10
    let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
    let itemWidth = availableWidth / 3
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 70)
    
    return flowLayout
  }
}
