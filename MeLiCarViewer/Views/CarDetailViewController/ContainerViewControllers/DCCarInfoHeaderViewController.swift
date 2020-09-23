//
//  DCCarInfoHeaderViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/21/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCCarInfoHeaderViewController: UIViewController {
  
  let carImageView = DCCarImageView(frame: .zero)
  let yearKmLabel = DCSubtitleLabel(textAlignment: .left, fontSize: 12, fontWeight: .regular)
  let carTitleLabel = DCTitleLabel(textAlignment: .left, fontSize: 20)
  let priceLabel = DCSubtitleLabel(textAlignment: .left, fontSize: 28)
  
  public var porscheResult: CarResult!
  public var porschePicturesInformation: CarPicturesInformation!
  
  init(porscheResult: CarResult) {
    super.init(nibName: nil, bundle: nil)
    self.porscheResult = porscheResult
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addSubviews()
    layoutUI()
    configueUIElements()
  }
  
  func configueUIElements() {
    print("Publicado el \(porschePicturesInformation.dateCreated.convertToDisplayFormat())")
    carImageView.image = UIImage(data: (porschePicturesInformation.images?.first)!)
    carTitleLabel.text = porscheResult.title
    priceLabel.text = porscheResult.price.convertToPriceInCOP()
    yearKmLabel.text = createYearKmText(porscheResult)
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
  
  func addSubviews() {
    view.addSubview(carImageView)
    view.addSubview(yearKmLabel)
    view.addSubview(carTitleLabel)
    view.addSubview(priceLabel)
  }
  
  func layoutUI() {
    let padding: CGFloat = 8
    
    NSLayoutConstraint.activate([
      carImageView.topAnchor.constraint(equalTo: view.topAnchor),
      carImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      carImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      carImageView.heightAnchor.constraint(equalToConstant: view.frame.height/3),
      
      yearKmLabel.topAnchor.constraint(equalTo: carImageView.bottomAnchor, constant: padding),
      yearKmLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      yearKmLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      yearKmLabel.heightAnchor.constraint(equalToConstant: 14),
      
      carTitleLabel.topAnchor.constraint(equalTo: yearKmLabel.bottomAnchor, constant: padding),
      carTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      carTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      carTitleLabel.heightAnchor.constraint(equalToConstant: 22),
      
      priceLabel.topAnchor.constraint(equalTo: carTitleLabel.bottomAnchor, constant: padding),
      priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      priceLabel.heightAnchor.constraint(equalToConstant: 30),
      
      
      
    ])
    
  }
  
}
