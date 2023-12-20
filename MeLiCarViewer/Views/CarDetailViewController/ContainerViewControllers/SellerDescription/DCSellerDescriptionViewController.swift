//
//  DCSellerDescriptionViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/24/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCSellerDescriptionViewController: UIViewController {
  let descriptionTitleLabel = DCTitleLabel(textAlignment: .left, fontSize: 16)
  let completeStackView = UIStackView()

  let sellerNameAttributeView = DCTitleSubtitleAttributeView()
  let sellerLocationAttributeView = DCTitleSubtitleAttributeView()
  let carConditionAttributeView = DCTitleSubtitleAttributeView()
  let singleOwnerAttributeView = DCTitleSubtitleAttributeView()

  public var porscheResult: CarResult!

  init(porscheResult: CarResult) {
    super.init(nibName: nil, bundle: nil)
    self.porscheResult = porscheResult
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureBackgroundView()
    layoutUI()
    configureStackView()
    configureAttributeViews()
  }

  private func configureBackgroundView() {
    view.layer.cornerRadius = 18
    view.backgroundColor = .secondarySystemBackground
  }

  private func layoutUI() {
    view.addSubviews(descriptionTitleLabel, completeStackView)
    
    descriptionTitleLabel.text = "Información de Venta:"
    descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    completeStackView.translatesAutoresizingMaskIntoConstraints = false
    
    let padding: CGFloat = 8
    
    NSLayoutConstraint.activate([
      descriptionTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
      descriptionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      descriptionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      descriptionTitleLabel.heightAnchor.constraint(equalToConstant: 18),
      
      completeStackView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: padding),
      completeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      completeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      completeStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
    ])
    
  }

  private func configureStackView() {
    completeStackView.axis = .vertical
    completeStackView.distribution = .fillProportionally
    completeStackView.spacing = 8

    let arrayOfViews = [sellerNameAttributeView,sellerLocationAttributeView,carConditionAttributeView,singleOwnerAttributeView]

    for view in arrayOfViews {
      completeStackView.addArrangedSubview(view)
    }
  }

  private func configureAttributeViews() {
    let sellerContactName = porscheResult.sellerContact.contact.isEmpty ? "No Disponible" : porscheResult.sellerContact.contact.capitalized
      let sellerNameAttribute = porscheResult.seller.carDealer ?? false ? "Concesionario" : sellerContactName
    sellerNameAttributeView.setAttribute(title: "Vendedor", value: sellerNameAttribute)

    var sellerLocationAttribute = ""

    if let neighborhood = porscheResult.location.neighborhood?.name {
        sellerLocationAttribute += "\(neighborhood) - "
    }

    if let city = porscheResult.location.city?.name {
        sellerLocationAttribute += "\(city), "
    }

    if let state = porscheResult.location.state?.name {
        sellerLocationAttribute += "\(state)"
    }
    
    sellerLocationAttributeView.setAttribute(title: "Ubicación del vehículo", value: sellerLocationAttribute.isEmpty ? "No disponible" : sellerLocationAttribute)
    
    let carConditionAttribute = porscheResult.attributes.first(where: { $0.id == "ITEM_CONDITION" })
    carConditionAttributeView.setAttribute(title: "Condición del carro", value: carConditionAttribute?.valueName ?? "-")
    
    let singleOwnerAttribute = porscheResult.attributes.first(where: { $0.id == "SINGLE_OWNER" })
    singleOwnerAttributeView.setAttribute(title: singleOwnerAttribute?.name ?? "Único dueño", value: singleOwnerAttribute?.valueName ?? "-")
  }
}
