//
//  SearchViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var modelTextField: UITextField!
  @IBOutlet weak var modelPicker: UIPickerView!
  
  var controller: SearchController = .init()
  var selectedCarModel: CarModel? = nil
  
  @IBAction func searchAction(_ sender: UIButton) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    modelPicker.delegate = self
    modelTextField.inputView = modelPicker
    createToolbar()
    
    controller.fetchPorscheModels {[weak self] success in
      print("Success: \(success)")
      print(self?.controller.porscheModels!)
    }
  }
  
  func createToolbar() {
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.sizeToFit()
    
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(SearchViewController.donePicker))
    
    toolBar.setItems([spaceButton,doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    
    modelTextField.inputAccessoryView = toolBar
  }
  
  @objc func donePicker() {
    view.endEditing(true)
  }
}

extension SearchViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return controller.porscheModels?.count ?? 0
  }
}

extension SearchViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    guard let carModel = controller.porscheModels?[row] else {
      return nil
    }
    return carModel.name
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedCarModel = controller.porscheModels?[row]
    modelTextField.text = selectedCarModel?.name
  }
}
