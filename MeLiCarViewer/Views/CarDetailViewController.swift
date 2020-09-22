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
  
  var controller: CarDetailController = .init(porscheResult: nil)
  
  init(carResult: CarResult) {
    super.init(nibName: nil, bundle: nil)
    self.car = carResult
    self.controller = CarDetailController(porscheResult: self.car)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
    navigationItem.rightBarButtonItem = doneButton
    
    configurePagedImage()
    print(car.title)
  }
  
  @objc func dismissVC() {
    dismiss(animated: true)
  }
  
  func configurePagedImage() {
    //var pagedImages:[UIImage] = []
    let pagedImageOne = UIImageView(image: UIImage(named: "CarPlaceholder"))
    pagedImageOne.frame = view.bounds
    view.addSubview(pagedImageOne)
    
    controller.searchPorschePictures(forPorscheId: car.id) { [weak self] (result) in
      guard let self = self else { return }
      
      switch result {
      case .success(let pictures):
        self.controller.startDownload(for: pictures) {
          print("Downloaded \(pictures.count) pictures")
          if let imageData = self.controller.porschePicturesInformation?.images?.first,
            let firstImage = UIImage(data: imageData) {
            print("First image assigned \(firstImage)")
            pagedImageOne.image = firstImage
            
          } else {
            print("No image assigned")
          }
        }
      case .failure(let error):
        self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.errorInfo ?? DataLoader.noErrorDescription, buttonTitle: "OK")
        // TODO: Replace this with os_log
        print(error.errorInfo ?? DataLoader.noErrorDescription)
      }
    }
  }
}
