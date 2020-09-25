//
//  CarResultsViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarResultsViewController: DCDataLoadingViewController {
  enum Section {
    case main
  }

  var isSearching = false
  var isLoadingMoreCars = false
  
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, CarResult>!
  
  var controller: CarResultsController = .init(carModel: nil)
  
  init(selectedCarModel: CarModel?) {
    super.init(nibName: nil, bundle: nil)
    self.title = "All Porsche Models"
    if let modelName = selectedCarModel?.name, !modelName.isEmpty {
      self.title = "Porsche " + modelName
    }
    self.controller = CarResultsController(carModel: selectedCarModel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    configureSearchController()
    configureCollectionView()
    searchPorscheModel(withPage: controller.page)
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
    collectionView.backgroundColor = .secondarySystemBackground
    collectionView.register(CarViewCell.self, forCellWithReuseIdentifier: CarViewCell.reuseID)

    collectionView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func configureSearchController() {
    let searchController = UISearchController()
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search for a Porsche"
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.searchController = searchController
  }
  
  func searchPorscheModel(withPage page: Int) {
    showLoadingView()
    isLoadingMoreCars = true

    controller.searchPorscheModel(controller.porscheModelToSearch?.id, page: page) { [weak self] (result) in
      guard let self = self else { return }
      self.dismissLoadingView()
      
      switch result {
      case .success(_):
        self.updateUI(with: self.controller.porscheModelsResult)
      case .failure(let error):
        self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.type.rawValue, buttonTitle: "OK")
        // TODO: Replace this with os_log
        print(error.errorInfo ?? DataLoader.noErrorDescription)
      }

      self.isLoadingMoreCars = false
    }
  }

  func updateUI(with carResults:CarModelResult?) {
    guard let _ = carResults else {
      presentDCAlertOnMainThread(title: "No cars", message: "There are no cars to show. Verify your internet connection and try again.", buttonTitle: "OK")
      return
    }

    if self.controller.carsResults.isEmpty {
      let message = "There are no Porsche \(controller.porscheModelToSearch?.name ?? "of the selected model") for sale right now 😢."
      DispatchQueue.main.async {
        self.showEmptyStateView(with: message, in: self.view)
      }
      return
    }

    self.updateData(on: self.controller.carsResults)
  }
  
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, CarResult>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, car) -> UICollectionViewCell? in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarViewCell.reuseID, for: indexPath) as! CarViewCell
      cell.set(car)
      return cell
    })
  }

  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView.collectionViewLayout.invalidateLayout()
    DispatchQueue.main.async {
      self.collectionView.setNeedsLayout()
      self.collectionView.reloadData()
    }
  }
  
  func updateData(on results: [CarResult]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, CarResult>()
    snapshot.appendSections([.main])
    snapshot.appendItems(results)
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
      guard controller.hasMoreResults, !isLoadingMoreCars else {
        return
      }
      controller.page += 1
      searchPorscheModel(withPage: controller.page)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let activeArray = isSearching ? controller.filteredCarsResults : controller.carsResults
    let car = activeArray[indexPath.item]
    
    let destinationViewController = CarDetailViewController(carResult: car)
    let navigationController = UINavigationController(rootViewController: destinationViewController)
    present(navigationController, animated: true)
  }
}

extension CarResultsViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let filter = searchController.searchBar.text, !filter.isEmpty else {
      controller.filteredCarsResults.removeAll()
      updateData(on: controller.carsResults)
      isSearching = false
      return
      
    }
    
    isSearching = true
    
    controller.filteredCarsResults = controller.carsResults.filter{ $0.title.lowercased().contains(filter.lowercased()) }
    print(controller.filteredCarsResults.count)
    updateData(on: controller.filteredCarsResults)
  }
}
