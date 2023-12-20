//
//  CarModelTests.swift
//  MeLiCarViewerTests
//
//  Created by David A Cespedes R on 9/25/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

@testable import MeLiCarViewer
import XCTest

class CarModelTests: XCTestCase {
    var dataLoader = DataLoader()

    func testCarModel_WhenDecoding_ParametersShouldBeCorrect() throws {
        // Given
        let filename = "PorscheModels"
        let carModel = CarModel(id: "60259", name: "911", metric: 15)

        // When
        do {
            guard let data = try dataLoader.loadJSON(fileName: filename) else {
                XCTFail("Could not get data for filename: \(filename)")
                throw DCError(type: .unableToDecode, errorInfo: "Could not get data for filename: \(filename)")
            }
            let decodedResponse = try JSONDecoder().decode([CarModel].self, from: data)
            guard let decodedCarModel = decodedResponse.first(where: { $0.id == "60259" }) else {
                XCTFail("No car model with id \(carModel.id)")
                return
            }
            // Then
            XCTAssertEqual(carModel.id, decodedCarModel.id, "The decoded model id: \(decodedCarModel.id) is not equal to \(carModel.id)")
            XCTAssertEqual(carModel.name, decodedCarModel.name, "The decoded model name: \(decodedCarModel.name) is not equal to \(carModel.name)")
        } catch {
            XCTFail("The was an error decoding the models \(error)")
        }
    }
}
