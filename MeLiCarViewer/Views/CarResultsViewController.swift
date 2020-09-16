//
//  CarResultsViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarResultsViewController: UIViewController {
  var selectedCarModel: CarModel?
  
  var controller: CarResultsController = .init(carModel: nil)
  
  init(selectedCarModel: CarModel?) {
    super.init(nibName: nil, bundle: nil)
    self.selectedCarModel = selectedCarModel
    self.controller = CarResultsController(carModel: selectedCarModel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    navigationController?.navigationBar.prefersLargeTitles = true
    
    controller.searchPorscheModel(selectedCarModel?.id) { (result) in
      switch result {
      case .success(let carResults):
        print(carResults)
        break
      case .failure(let error):
        // TODO: Show an Alert with the error to the user
        print(error.errorInfo ?? DataLoader.noErrorDescription)
        break
      }

    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
}
