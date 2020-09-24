//
//  SearchViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {


  @IBOutlet weak var modelTextField: DCTextField!
  @IBOutlet weak var searchButton: DCButton!
  @IBOutlet weak var modelPicker: UIPickerView!
  
  var controller: SearchController = .init()
  var selectedCarModel: CarModel? = nil
  
  @IBAction func searchAction(_ sender: UIButton) {
    guard let selectedCarModel = selectedCarModel else {
      presentDCAlertOnMainThread(title: "Empty Model", message: "Please select a Model. 😀", buttonTitle: "OK")
      return
    }
    
    let carResultsVC = CarResultsViewController(selectedCarModel: selectedCarModel)
    navigationController?.pushViewController(carResultsVC, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    modelPicker.delegate = self
    modelTextField.delegate = self
    modelTextField.inputView = modelPicker
    createToolbar()
    
    controller.fetchPorscheModels {[weak self] success in
      print("Success: \(success)")
      print(self?.controller.porscheModels! ?? "No models")
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  func createToolbar() {
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.sizeToFit()
    
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(SearchViewController.donePicker))
    
    toolBar.setItems([spaceButton,doneButton], animated: false)
    toolBar.updateConstraintsIfNeeded()
    toolBar.isUserInteractionEnabled = true
    toolBar.translatesAutoresizingMaskIntoConstraints = false
    
    modelTextField.inputAccessoryView = toolBar
  }
  
  func updateSelectedCarModel(withPickerRow row: Int) {
    selectedCarModel = controller.porscheModels?[row]
    modelTextField.text = selectedCarModel?.name
  }
  
  @objc func donePicker() {
    let selectedRow = modelPicker.selectedRow(inComponent: 0)
    updateSelectedCarModel(withPickerRow: selectedRow)
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
    updateSelectedCarModel(withPickerRow: row)
  }
}

extension SearchViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == modelTextField {
      let selectedRow = modelPicker.selectedRow(inComponent: 0)
      updateSelectedCarModel(withPickerRow: selectedRow)
    }
  }
}
