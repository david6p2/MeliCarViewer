//
//  DCSubtitleLabel.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/16/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class DCSubtitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat, fontWeight: UIFont.Weight = .bold) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }

    private func configure() {
        textColor = .secondaryLabel
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.75
        lineBreakMode = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }
}
