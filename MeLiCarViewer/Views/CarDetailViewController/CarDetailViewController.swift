//
//  CarDetailViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/19/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarDetailViewController: UIViewController {
  
  let headerView = UIView()
  let itemViewOne = UIView()
  let itemViewTwo = UIView()
  var itemViews: [UIView] = []
  
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
    configureViewController()
    layoutUI()
    getPorschePictures()
  }
  
  func configureViewController() {
    view.backgroundColor = .systemBackground
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
    navigationItem.rightBarButtonItem = doneButton
  }
  
  func getPorschePictures() {
    controller.searchPorschePictures(forPorscheId: car.id) { [weak self] (result) in
      guard let self = self else { return }
      
      switch result {
      case .success(let pictures):
        self.controller.startDownload(for: pictures) {
          DispatchQueue.main.async {
            self.configureUIElements(with: self.car, and: self.controller.porschePicturesInformation)
          }
        }
      case .failure(let error):
        self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.errorInfo ?? DataLoader.noErrorDescription, buttonTitle: "OK")
        // TODO: Replace this with os_log
        print(error.errorInfo ?? DataLoader.noErrorDescription)
      }
    }
  }
  
  func configureUIElements(with porscheResult: CarResult, and porschePicturesInformation: CarPicturesInformation?) {
    let carInfoHeaderVC = DCCarInfoHeaderViewController(porscheResult: self.controller.porscheResult)
    carInfoHeaderVC.porschePicturesInformation = self.controller.porschePicturesInformation
    let carDescriptionVC = DCCarDescriptionViewController(porscheResult: porscheResult)
    
    self.add(childViewController: carInfoHeaderVC, to: self.headerView)
    self.add(childViewController: carDescriptionVC, to: self.itemViewOne)
  }
  
  func layoutUI() {
    let padding: CGFloat = 20
    let itemHeight: CGFloat = 190
    itemViews = [headerView, itemViewOne, itemViewTwo]
    
    for itemView in itemViews {
      view.addSubview(itemView)
      itemView.translatesAutoresizingMaskIntoConstraints = false
      var cardPadding: CGFloat = 8
      if itemView === headerView {
        cardPadding = 0
      }
      NSLayoutConstraint.activate([
        itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cardPadding),
        itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -cardPadding)
      ])
    }
    
    itemViewTwo.backgroundColor = .systemBlue
    
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      headerView.heightAnchor.constraint(equalToConstant: view.frame.height/3 + 90),
      
      itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
      itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
      
      itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
      itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
    ])
  }
  
  func add(childViewController: UIViewController, to containerView: UIView) {
    addChild(childViewController)
    containerView.addSubview(childViewController.view)
    childViewController.view.frame = containerView.bounds
    childViewController.didMove(toParent: self)
  }
  
  @objc func dismissVC() {
    dismiss(animated: true)
  }
}
