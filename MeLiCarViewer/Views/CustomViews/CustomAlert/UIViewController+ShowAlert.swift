//
//  UIViewController+ShowAlert.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/16/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
  func presentDCAlertOnMainThread(title: String, message: String, buttonTitle: String) {
    DispatchQueue.main.async {
      let alertVC = DCAlertViewController(title: title, message: message, buttonTitle: buttonTitle)
      alertVC.modalPresentationStyle = .overFullScreen
      alertVC.modalTransitionStyle = .crossDissolve
      self.present(alertVC, animated: true)
    }
  }
  
  func showLoadingView() {
    containerView = UIView(frame: view.bounds)
    view.addSubview(containerView)
    
    containerView.backgroundColor = .systemBackground
    containerView.alpha = 0
    
    UIView.animate(withDuration: 0.25) {
      containerView.alpha = 0.8
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    containerView.addSubview(activityIndicator)
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    activityIndicator.startAnimating()
  }
  
  func dismissLoadingView() {
    DispatchQueue.main.async {
      containerView.removeFromSuperview()
      containerView = nil
    }
  }
  
  func showEmptyStateView(with message: String, in view: UIView) {
    let emptyStateView = DCEmptyStateView(message: message)
    emptyStateView.frame = view.bounds
    view.addSubview(emptyStateView)
  }
}
