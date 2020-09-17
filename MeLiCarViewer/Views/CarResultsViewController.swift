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
    searchPorscheModel()
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
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnFlowLayout())
    view.addSubview(collectionView)
    collectionView.backgroundColor = .systemBackground
    collectionView.register(CarViewCell.self, forCellWithReuseIdentifier: CarViewCell.reuseID)
  }
  
  func createThreeColumnFlowLayout() -> UICollectionViewFlowLayout {
    let width = view.bounds.width
    let padding: CGFloat = 12
    let minimumItemSpacing: CGFloat = 10
    let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
    let itemWidth = availableWidth / 3
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 92)
    
    return flowLayout
  }
  
  func searchPorscheModel() {
    controller.searchPorscheModel(selectedCarModel?.id) { (result) in
      switch result {
      case .success(let carResults):
        guard let carModelResult = carResults else {
          // TODO: Show an Alert with the error to the user
          return
        }
        // TODO: This should be done in the controller
        self.carsResults = carModelResult.results
        self.updateData()
      case .failure(let error):
        // TODO: Show an Alert with the error to the user
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
