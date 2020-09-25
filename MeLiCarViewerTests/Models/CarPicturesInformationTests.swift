//
//  CarPicturesInformationTests.swift
//  MeLiCarViewerTests
//
//  Created by David A Cespedes R on 9/25/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import XCTest
@testable import MeLiCarViewer

class CarPicturesInformationTests: XCTestCase {
  var dataLoader = DataLoader()
  
  func testCarModelResult_WhenDecoding_ParametersShouldBeCorrect() throws {
    // Given
    let pictureId = "621503-MCO42790393667_072020"
    let secureUrl = "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-O.jpg"
    let filename = "CarDetailsWithPictures"
    
    // When
    do {
      guard let data = try dataLoader.loadJSON(fileName: filename) else {
        XCTFail("Could not get data for filename: \(filename)")
        throw DCError(type: .unableToDecode, errorInfo: "Could not get data for filename: \(filename)")
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let decodedResponse = try decoder.decode(CarPicturesInformation.self, from: data)
      let decodedFirstPicture = decodedResponse.pictures.first
      // Then
      XCTAssertEqual(pictureId, decodedFirstPicture?.id, "The decoded picture id: \(decodedFirstPicture?.id ?? "N/A") is not equal to \(pictureId)")
      XCTAssertEqual(secureUrl, decodedFirstPicture?.secureUrl, "The decoded picture secureUrl: \(decodedFirstPicture?.secureUrl ?? "N/A") is not equal to \(secureUrl)")
    } catch {
      XCTFail("The was an error decoding the pictures \(error)")
    }
  }
  
}
