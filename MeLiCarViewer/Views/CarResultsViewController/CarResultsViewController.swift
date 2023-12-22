//
//  CarResultsViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/14/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Combine
import os.log
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
    var viewModel: CarResultsViewModel = .init(carModel: nil)
    var cancellables = Set<AnyCancellable>()

    init(selectedCarModel: CarModel?) {
        super.init(nibName: nil, bundle: nil)
        title = "All Porsche Models"
        if let modelName = selectedCarModel?.name, !modelName.isEmpty {
            title = "Porsche " + modelName
        }
        controller = CarResultsController(carModel: selectedCarModel)
        viewModel = CarResultsViewModel(carModel: selectedCarModel)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addViewModelBinding()
        configureViewController()
        configureSearchController()
        configureCollectionView()
        searchPorscheModel(withPage: viewModel.page)
        configureDataSource()
    }
    
    func addViewModelBinding() {
        viewModel.carModelResultPublisher.sink { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()

            switch result {
            case .success:
                self.updateUI(with: self.viewModel.porscheModelsResult)
            case let .failure(error):
                self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.type.rawValue, buttonTitle: "OK")
                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .carResultsVC, "%{public}@", errorInfo)
            }

            self.isLoadingMoreCars = false
        }.store(in: &cancellables)
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

        viewModel.searchPorscheModel(page: page)
        /*
        controller.searchPorscheModel(controller.porscheModelToSearch?.id, page: page) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()

            switch result {
            case .success:
                self.updateUI(with: self.controller.porscheModelsResult)
            case let .failure(error):
                self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.type.rawValue, buttonTitle: "OK")
                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .carResultsVC, "%{public}@", errorInfo)
            }

            self.isLoadingMoreCars = false
        }
         */
    }

    func updateUI(with carResults: CarModelResult?) {
        guard let _ = carResults else {
            presentDCAlertOnMainThread(title: "No cars", message: "There are no cars to show. Verify your internet connection and try again.", buttonTitle: "OK")
            return
        }

        if viewModel.carsResults.isEmpty {
            let message = "There are no Porsche \(viewModel.porscheModelToSearch?.name ?? "of the selected model") for sale right now 😢."
            DispatchQueue.main.async {
                self.showEmptyStateView(with: message, in: self.view)
            }
            return
        }

        updateData(on: viewModel.carsResults)
    }

    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CarResult>(collectionView: collectionView, cellProvider: { collectionView, indexPath, car -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarViewCell.reuseID, for: indexPath) as! CarViewCell
            cell.set(car)
            return cell
        })
    }

    override func willTransition(to _: UITraitCollection, with _: UIViewControllerTransitionCoordinator) {
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
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard viewModel.hasMoreResults, !isLoadingMoreCars else {
                return
            }
            viewModel.page += 1
            searchPorscheModel(withPage: viewModel.page)
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? viewModel.filteredCarsResults : viewModel.carsResults
        let car = activeArray[indexPath.item]

        let destinationViewController = CarDetailViewController(carResult: car)
        let navigationController = UINavigationController(rootViewController: destinationViewController)
        present(navigationController, animated: true)
    }
}

extension CarResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            viewModel.filteredCarsResults.removeAll()
            updateData(on: viewModel.carsResults)
            isSearching = false
            return
        }

        isSearching = true

        viewModel.filteredCarsResults = viewModel.carsResults.filter { $0.title.lowercased().contains(filter.lowercased()) }
        os_log(.debug, log: .carResultsVC, "%{public}@", String(viewModel.filteredCarsResults.count))
        updateData(on: viewModel.filteredCarsResults)
    }
}

private extension OSLog {
    static let carResultsVC = OSLog.meliCarViewer("carResultsVC")
}
