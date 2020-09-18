//
//  CarResultsViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarResultsViewController: UIViewController {
  enum Section {
    case main
  }
  
  var selectedCarModel: CarModel?
  var carsResults: [CarResult] = []
  
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, CarResult>!
  
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
    configureViewController()
    configureCollectionView()
    searchPorscheModel(withPage: self.controller.page)
    configureDataSource()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  func configureViewController() {
    view.backgroundColor = .systemBackground
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
    view.addSubview(collectionView)
    collectionView.delegate = self
    collectionView.backgroundColor = .systemBackground
    collectionView.register(CarViewCell.self, forCellWithReuseIdentifier: CarViewCell.reuseID)
  }
  
  func searchPorscheModel(withPage page: Int) {
    controller.searchPorscheModel(selectedCarModel?.id, page: page) { [weak self] (result) in
      guard let self = self else { return }
      switch result {
      case .success(let carResults):
        guard let carModelResult = carResults else {
          // TODO: Show an Alert with the error to the user
          return
        }
        // TODO: This should be done in the controller?
        self.carsResults.append(contentsOf: carModelResult.results)
        self.updateData()
      case .failure(let error):
        self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.errorInfo ?? DataLoader.noErrorDescription, buttonTitle: "OK")
        // TODO: Replace this with os_log
        print(error.errorInfo ?? DataLoader.noErrorDescription)
      }
    }
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, CarResult>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, car) -> UICollectionViewCell? in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarViewCell.reuseID, for: indexPath) as! CarViewCell
      cell.set(car)
      return cell
    })
  }
  
  func updateData() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, CarResult>()
    snapshot.appendSections([.main])
    snapshot.appendItems(carsResults)
    DispatchQueue.main.async {
      self.dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}

extension CarResultsViewController: UICollectionViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let offsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let height = scrollView.frame.size.height
    
    if offsetY > contentHeight - height {
      guard self.controller.hasMoreResults else {
        return
      }
      self.controller.page += 1
      searchPorscheModel(withPage: self.controller.page)
    }
  }
}
