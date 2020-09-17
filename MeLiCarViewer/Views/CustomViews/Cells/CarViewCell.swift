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
  
  func set(_ car: CarResult) {
    carTitleLabel.text = car.title
    priceLabel.text = String(car.price)
    yearKmLabel.text = createYearKmText(car)
  }
  
  private func createYearKmText(_ car: CarResult) -> String {
    let kmAttribute = car.attributes.first { (attribute) -> Bool in
      return attribute.id == "KILOMETERS"
    }
    
    let yearAttribute = car.attributes.first { (attribute) -> Bool in
      return attribute.id == "VEHICLE_YEAR"
    }
    
    return (yearAttribute?.valueName ?? " ") + " - " + (kmAttribute?.valueName ?? " ")
  }
  
  private func configure() {
    configureCarImageView()
    configureCarTitleLabel()
    configurePriceLabel()
    configureYearKmLabel()
  }
  
  private func configureCarImageView() {
    addSubview(carImageView)
    
    NSLayoutConstraint.activate([
      carImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
      carImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      carImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      carImageView.heightAnchor.constraint(equalTo: carImageView.widthAnchor)
    ])
  }
  
  private func configureCarTitleLabel() {
    addSubview(carTitleLabel)
    
    carTitleLabel.numberOfLines = 2
    
    NSLayoutConstraint.activate([
      carTitleLabel.topAnchor.constraint(equalTo: carImageView.bottomAnchor, constant: padding),
      carTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      carTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      carTitleLabel.heightAnchor.constraint(equalToConstant: 24)
    ])
  }
  
  private func configurePriceLabel() {
    addSubview(priceLabel)
    
    NSLayoutConstraint.activate([
      priceLabel.topAnchor.constraint(equalTo: carTitleLabel.bottomAnchor, constant: padding),
      priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      priceLabel.heightAnchor.constraint(equalToConstant: 18)
    ])
  }
  
  private func configureYearKmLabel() {
    addSubview(yearKmLabel)
    
    NSLayoutConstraint.activate([
      yearKmLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: padding),
      yearKmLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      yearKmLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      yearKmLabel.heightAnchor.constraint(equalToConstant: 10)
    ])
  }
}
