//
//  UIViewController+ShowAlert.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/16/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentDCAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = DCAlertViewController(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
}
