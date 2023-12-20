//
//  CarResultTests.swift
//  MeLiCarViewerTests
//
//  Created by David A Cespedes R on 9/25/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

@testable import MeLiCarViewer
import XCTest

class CarResultTests: XCTestCase {
    var dataLoader = DataLoader()

    func testCarModelResult_WhenDecoding_ParametersShouldBeCorrect() throws {
        // Given
        let carResultId = "MCO575110499"
        let filename = "SearchByModelAndCategory"

        // When
        do {
            guard let data = try dataLoader.loadJSON(fileName: filename) else {
                XCTFail("Could not get data for filename: \(filename)")
                throw DCError(type: .unableToDecode, errorInfo: "Could not get data for filename: \(filename)")
            }
            let decodedResponse = try JSONDecoder().decode(CarModelResult.self, from: data)
            let decodedFirstCarResul = decodedResponse.results.first
            // Then
            XCTAssertEqual(carResultId, decodedFirstCarResul?.id, "The decoded car id: \(decodedFirstCarResul?.id ?? "N/A") is not equal to \(carResultId)")
        } catch {
            XCTFail("The was an error decoding the cars \(error)")
        }
    }
}
