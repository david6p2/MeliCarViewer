//
//  SearchViewController.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/13/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Combine
import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var modelTextField: DCTextField!
    @IBOutlet var searchButton: DCButton!
    var modelPicker: UIPickerView!

    var viewModel: SearchViewViewModel = .init()
    var cancellables = Set<AnyCancellable>()

    var selectedCarModel: CarModel? = nil

    @IBAction func searchAction(_: UIButton) {
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
        modelPicker = UIPickerView()
        modelPicker.delegate = self
        modelTextField.delegate = self
        modelTextField.inputView = modelPicker
        createToolbar()

        viewModel.errorPublisher.sink { error in
            self.presentDCAlertOnMainThread(
                title: "Invalid Models",
                message: "We were unable to load the Porsche models you selected. Please try again.",
                buttonTitle: "OK"
            )
        }
        .store(in: &cancellables)

        viewModel.fetchPorscheModels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func createToolbar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(SearchViewController.donePicker))

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.updateConstraintsIfNeeded()
        toolBar.isUserInteractionEnabled = true
        toolBar.translatesAutoresizingMaskIntoConstraints = false

        modelTextField.inputAccessoryView = toolBar
    }

    private func updateSelectedCarModel(withPickerRow row: Int) {
        selectedCarModel = viewModel.porscheModels?[row]
        modelTextField.text = selectedCarModel?.name
    }

    @objc private func donePicker() {
        let selectedRow = modelPicker.selectedRow(inComponent: 0)
        updateSelectedCarModel(withPickerRow: selectedRow)
        view.endEditing(true)
    }
}

// MARK: UIPickerViewDataSource

extension SearchViewController: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return viewModel.porscheModels?.count ?? 0
    }
}

extension SearchViewController: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        guard let carModel = viewModel.porscheModels?[row] else {
            return nil
        }
        return carModel.name
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        updateSelectedCarModel(withPickerRow: row)
    }
}

// MARK: UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == modelTextField {
            let selectedRow = modelPicker.selectedRow(inComponent: 0)
            updateSelectedCarModel(withPickerRow: selectedRow)
        }
    }
}
