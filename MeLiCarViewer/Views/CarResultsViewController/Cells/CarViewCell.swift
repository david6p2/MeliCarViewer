//
//  CarViewCell.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/15/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class CarViewCell: UICollectionViewCell {
    static let reuseID = "CarViewCell"

    let padding: CGFloat = 4

    let carImageView = DCCarImageView(frame: .zero)
    let carTitleLabel = DCTitleLabel(textAlignment: .left, fontSize: 10)
    let priceLabel = DCSubtitleLabel(textAlignment: .left, fontSize: 14)
    let yearKmLabel = DCSubtitleLabel(textAlignment: .left, fontSize: 8, fontWeight: .regular)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        configureCellView()
        configureCarImageView()
        configureCarTitleLabel()
        configurePriceLabel()
        configureYearKmLabel()
    }

    private func configureCellView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        clipsToBounds = true
        contentView.addSubviews(carImageView, carTitleLabel, priceLabel, yearKmLabel)
    }

    private func configureCarImageView() {
        NSLayoutConstraint.activate([
            carImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            carImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            carImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            carImageView.heightAnchor.constraint(equalTo: carImageView.widthAnchor),
        ])
    }

    private func configureCarTitleLabel() {
        carTitleLabel.numberOfLines = 2

        NSLayoutConstraint.activate([
            carTitleLabel.topAnchor.constraint(equalTo: carImageView.bottomAnchor, constant: padding),
            carTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            carTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            carTitleLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    private func configurePriceLabel() {
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: carTitleLabel.bottomAnchor, constant: padding),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            priceLabel.heightAnchor.constraint(equalToConstant: 18),
        ])
    }

    private func configureYearKmLabel() {
        NSLayoutConstraint.activate([
            yearKmLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: padding),
            yearKmLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            yearKmLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            yearKmLabel.heightAnchor.constraint(equalToConstant: 10),
        ])
    }

    private func createYearKmText(_ car: CarResult) -> String {
        let kmAttribute = car.attributes.first { attribute -> Bool in
            attribute.id == "KILOMETERS"
        }

        let yearAttribute = car.attributes.first { attribute -> Bool in
            attribute.id == "VEHICLE_YEAR"
        }

        return (yearAttribute?.valueName ?? " ") + " - " + (kmAttribute?.valueName ?? " ")
    }

    func set(_ car: CarResult) {
        carTitleLabel.text = car.title
        priceLabel.text = car.price.convertToPriceInCOP()
        yearKmLabel.text = createYearKmText(car)
        carImageView.setImage(from: car.thumbnail)
    }
}
