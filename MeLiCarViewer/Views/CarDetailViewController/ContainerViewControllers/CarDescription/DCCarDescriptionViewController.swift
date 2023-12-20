//
//  DCCarDescriptionViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/23/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCCarDescriptionViewController: UIViewController {
    let descriptionTitleLabel = DCTitleLabel(textAlignment: .left, fontSize: 16)
    let completeStackView = UIStackView()

    let brandAttributeView = DCTitleSubtitleAttributeView()
    let modelAttributeView = DCTitleSubtitleAttributeView()

    let versionAttributeView = DCTitleSubtitleAttributeView()
    let vehicleYearAttributeView = DCTitleSubtitleAttributeView()

    let engineDisplacementAttributeView = DCTitleSubtitleAttributeView()
    let kilometersAttributeView = DCTitleSubtitleAttributeView()

    let doorsAttributeView = DCTitleSubtitleAttributeView()
    let fuelTypeAttributeView = DCTitleSubtitleAttributeView()

    public var porscheResult: CarResult!

    init(porscheResult: CarResult) {
        super.init(nibName: nil, bundle: nil)
        self.porscheResult = porscheResult
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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

        descriptionTitleLabel.text = "Descripción:"
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
            completeStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
        ])
    }

    private func configureStackView() {
        completeStackView.axis = .vertical
        completeStackView.distribution = .fillProportionally
        completeStackView.spacing = 8

        let firstHStack = UIStackView()
        let secondHStack = UIStackView()
        let thirdHStack = UIStackView()
        let fourthHStack = UIStackView()

        let arrayOfHStacks = [firstHStack, secondHStack, thirdHStack, fourthHStack]

        firstHStack.addArrangedSubview(brandAttributeView)
        firstHStack.addArrangedSubview(modelAttributeView)

        secondHStack.addArrangedSubview(versionAttributeView)
        secondHStack.addArrangedSubview(vehicleYearAttributeView)

        thirdHStack.addArrangedSubview(engineDisplacementAttributeView)
        thirdHStack.addArrangedSubview(kilometersAttributeView)

        fourthHStack.addArrangedSubview(doorsAttributeView)
        fourthHStack.addArrangedSubview(fuelTypeAttributeView)

        for stack in arrayOfHStacks {
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.alignment = .top
            completeStackView.addArrangedSubview(stack)
        }
    }

    private func configureAttributeViews() {
        let brandAttribute = porscheResult.attributes.first(where: { $0.id == "BRAND" })
        brandAttributeView.setAttribute(title: brandAttribute?.name ?? "Marca", value: brandAttribute?.valueName ?? "Porsche")

        let modelAttribute = porscheResult.attributes.first(where: { $0.id == "MODEL" })
        modelAttributeView.setAttribute(title: modelAttribute?.name ?? "Modelo", value: modelAttribute?.valueName ?? "911")

        let versionAttribute = porscheResult.attributes.first(where: { $0.id == "TRIM" })
        versionAttributeView.setAttribute(title: versionAttribute?.name ?? "Versión", value: versionAttribute?.valueName ?? "-")

        let vehicleYearAttribute = porscheResult.attributes.first(where: { $0.id == "VEHICLE_YEAR" })
        vehicleYearAttributeView.setAttribute(title: vehicleYearAttribute?.name ?? "Año", value: vehicleYearAttribute?.valueName ?? "-")

        let engineDisplacementAttribute = porscheResult.attributes.first(where: { $0.id == "ENGINE_DISPLACEMENT" })
        engineDisplacementAttributeView.setAttribute(title: engineDisplacementAttribute?.name ?? "Cilindrada", value: engineDisplacementAttribute?.valueName ?? "- cc")

        let kilometersAttribute = porscheResult.attributes.first(where: { $0.id == "KILOMETERS" })
        kilometersAttributeView.setAttribute(title: kilometersAttribute?.name ?? "Kilómetros", value: kilometersAttribute?.valueName ?? "- km")

        let doorsAttribute = porscheResult.attributes.first(where: { $0.id == "DOORS" })
        doorsAttributeView.setAttribute(title: doorsAttribute?.name ?? "Puertas", value: doorsAttribute?.valueName ?? "-")

        let fuelTypeAttribute = porscheResult.attributes.first(where: { $0.id == "FUEL_TYPE" })
        fuelTypeAttributeView.setAttribute(title: fuelTypeAttribute?.name ?? "Tipo de combustible", value: fuelTypeAttribute?.valueName ?? "-")
    }
}
