//
//  DCTitleSubtitleAttributeView.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/23/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCTitleSubtitleAttributeView: UIView {
    let attributeTitleLabel = DCSubtitleLabel(textAlignment: .left, fontSize: 10, fontWeight: .medium)
    let attributeValueLabel = DCTitleLabel(textAlignment: .left, fontSize: 12)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        attributeTitleLabel.numberOfLines = 0
        attributeValueLabel.numberOfLines = 0
        addSubviews(attributeTitleLabel, attributeValueLabel)

        NSLayoutConstraint.activate([
            attributeTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            attributeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            attributeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            attributeTitleLabel.heightAnchor.constraint(equalToConstant: 12),

            attributeValueLabel.topAnchor.constraint(equalTo: attributeTitleLabel.bottomAnchor, constant: 2),
            attributeValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            attributeValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            attributeValueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 14),
            attributeValueLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 8),
        ])
    }

    func setAttribute(title: String, value: String) {
        attributeTitleLabel.text = title
        attributeValueLabel.text = value
    }
}
