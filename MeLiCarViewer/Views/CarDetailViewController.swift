//
//  CarDetailViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/19/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarDetailViewController: UIViewController {
  
  var car: CarResult!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
    navigationItem.rightBarButtonItem = doneButton
    
    print(car.title)
  }
  
  @objc func dismissVC() {
    dismiss(animated: true)
  }
}
