//
//  CarDetailViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/19/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import os.log
import UIKit

class CarDetailViewController: DCDataLoadingViewController {
    let scrollView = UIScrollView()

    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    var itemViews: [UIView] = []

    static let padding: CGFloat = 20
    static let itemHeight: CGFloat = 200

    var car: CarResult!

    var controller: CarDetailController = .init(porscheResult: nil)

    init(carResult: CarResult) {
        super.init(nibName: nil, bundle: nil)
        car = carResult
        controller = CarDetailController(porscheResult: car)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        layoutUI()
        calculateScrollViewContentSize()
        getPorschePictures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateScrollViewContentSize()
    }

    override func willTransition(to _: UITraitCollection, with _: UIViewControllerTransitionCoordinator) {
        scrollView.invalidateIntrinsicContentSize()

        DispatchQueue.main.async {
            self.scrollView.setNeedsLayout()
            self.calculateScrollViewContentSize()
        }
    }

    private func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }

    func getPorschePictures() {
        controller.searchPorschePictures(forPorscheId: car.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(pictures):
                self.controller.startDownload(for: pictures) {
                    DispatchQueue.main.async {
                        self.configureUIElements(with: self.car, and: self.controller.porschePicturesInformation)
                        self.calculateScrollViewContentSize()
                    }
                }
            case let .failure(error):
                self.presentDCAlertOnMainThread(title: "Something went wrong", message: error.type.rawValue, buttonTitle: "OK")

                let errorInfo = error.errorInfo ?? DataLoader.noErrorDescription
                os_log(.debug, log: .carDetailVC, "%{public}@", errorInfo)
            }
        }
    }

    private func configureUIElements(with porscheResult: CarResult, and _: CarPicturesInformation?) {
        let carInfoHeaderVC = DCCarInfoHeaderViewController(porscheResult: controller.porscheResult)
        carInfoHeaderVC.porschePicturesInformation = controller.porschePicturesInformation
        let carDescriptionVC = DCCarDescriptionViewController(porscheResult: porscheResult)
        let sellerDescriptionVC = DCSellerDescriptionViewController(porscheResult: porscheResult)

        add(childViewController: carInfoHeaderVC, to: headerView)
        add(childViewController: carDescriptionVC, to: itemViewOne)
        add(childViewController: sellerDescriptionVC, to: itemViewTwo)
    }

    private func layoutUI() {
        itemViews = [headerView, itemViewOne, itemViewTwo]

        layoutScrollView()

        for itemView in itemViews {
            scrollView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            var cardPadding: CGFloat = 8

            if itemView === headerView {
                cardPadding = 0
            }

            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: cardPadding),
                itemView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -cardPadding),
                itemView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -cardPadding * 2),
            ])
        }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: view.frame.height / 3 + 112),

            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Self.padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: Self.itemHeight),

            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: Self.padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: Self.itemHeight),
        ])
    }

    private func layoutScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func calculateScrollViewContentSize() {
        let scrollViewHeight = headerView.frame.height + Self.padding + itemViewOne.frame.height + Self.padding + itemViewTwo.frame.height + Self.padding
        scrollView.contentSize = CGSize(width: view.frame.width, height: scrollViewHeight)
    }

    private func add(childViewController: UIViewController, to containerView: UIView) {
        addChild(childViewController)
        containerView.addSubview(childViewController.view)
        childViewController.view.frame = containerView.bounds
        childViewController.didMove(toParent: self)
    }

    @objc func dismissVC() {
        dismiss(animated: true)
    }
}

private extension OSLog {
    static let carDetailVC = OSLog.meliCarViewer("carDetailVC")
}
