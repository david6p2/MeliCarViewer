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
  var filteredCarsResults: [CarResult] = []
  var isSearching = false
  
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, CarResult>!
  
  var controller: CarResultsController = .init(carModel: nil)
  
  init(selectedCarModel: CarModel?) {
    super.init(nibName: nil, bundle: nil)
    self.selectedCarModel = selectedCarModel
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
    searchController.searchBar.delegate = self
    searchController.searchBar.placeholder = "Search for a Porsche"
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.searchController = searchController
    
  }
  
  func searchPorscheModel(withPage page: Int) {
    showLoadingView()
    controller.searchPorscheModel(selectedCarModel?.id, page: page) { [weak self] (result) in
      guard let self = self else { return }
      self.dismissLoadingView()
      
      switch result {
      case .success(let carResults):
        guard let carModelResult = carResults else {
          // TODO: Show an Alert with the error to the user
          return
        }
        // TODO: This should be done in the controller?
        self.carsResults.append(contentsOf: carModelResult.results)
        
        if self.carsResults.isEmpty {
          let message = "There are no Porsche \(self.selectedCarModel?.name ?? "of the selected model") for sale right now 😢."
          DispatchQueue.main.async {
            self.showEmptyStateView(with: message, in: self.view)
          }
          return
        }
        
        self.updateData(on: self.carsResults)
        
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
      guard controller.hasMoreResults else {
        return
      }
      controller.page += 1
      searchPorscheModel(withPage: controller.page)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let activeArray = isSearching ? filteredCarsResults : carsResults
    let car = activeArray[indexPath.item]
    
    let destinationViewController = CarDetailViewController(carResult: car)
    let navigationController = UINavigationController(rootViewController: destinationViewController)
    present(navigationController, animated: true)
  }
}

extension CarResultsViewController: UISearchResultsUpdating, UISearchBarDelegate {
  func updateSearchResults(for searchController: UISearchController) {
    guard let filter = searchController.searchBar.text, !filter.isEmpty else {
      filteredCarsResults.removeAll()
      updateData(on: carsResults)
      return
      
    }
    
    isSearching = true
    
    filteredCarsResults = carsResults.filter{ $0.title.lowercased().contains(filter.lowercased()) }
    print(filteredCarsResults.count)
    updateData(on: filteredCarsResults)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    isSearching = false
    filteredCarsResults.removeAll()
    updateData(on: carsResults)
  }
}
