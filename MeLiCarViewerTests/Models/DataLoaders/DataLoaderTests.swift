//
//  DataLoaderTests.swift
//  MeLiCarViewerTests
//
//  Created by David A Cespedes R on 9/25/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import XCTest
@testable import MeLiCarViewer

class DataLoaderTests: XCTestCase {
  let dataLoader = DataLoader()
  let carResultId = "MCO575110499"
  let carId = "60259"

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    dataLoader.defaultSession = URLSession(configuration: configuration)
  }

  override func tearDownWithError() throws {
    DataLoader.cache.removeAllObjects()
  }

  // MARK: SearchResultsForCarModel Methods

  func testMakeUrlForCarModel_WhenModelIsPassed_ThenItShouldReturnTheCorrectURL() throws {
    let carModelId = "60259"
    let page = 1
    let limit = 10
    let offset = (page - 1) * limit
    let queryParameter = "MODEL="+carModelId

    let url = try dataLoader.makeUrlForCarModel(carModelId, withPage: page)

    XCTAssertEqual(url?.scheme, "https")
    XCTAssertEqual(url?.host, "api.mercadolibre.com")
    XCTAssertEqual(url?.query, "category=MCO1744&limit=\(limit)&offset=\(offset)&\(queryParameter)")
  }

  func testParseResponseForCarModelDataResult_WhenTheJSONFileIsLoaded_ThenTheCorrectDataShouldBeReturned() throws {
    let filename = "SearchByModelAndCategory"
    
    guard let jsonData = try dataLoader.loadJSON(fileName: filename) else {
      XCTFail("Could not get data for filename: \(filename)")
      throw DCError(type: .unableToDecode, errorInfo: "Could not get data for filename: \(filename)")
    }

    let response = try dataLoader.parseResponseForCarModelDataResult(data: jsonData)
    let decodedFirstCarResul = response.results.first
    XCTAssertEqual(carResultId, decodedFirstCarResul?.id, "The decoded car id: \(decodedFirstCarResul?.id ?? "N/A") is not equal to \(carResultId)")
  }

  func testSearchResultsForCarModel_WhenTheMethodIsCalled_ThenTheCompletionHandlerIsExecuted() {
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: "https://api.mercadolibre.com/sites/MCO/search?category=MCO1744&limit=10&offset=0&MODEL=MCO575110499"))
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.searchResultsForCarModel(carResultId, withPage: 1) { (result) in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testSearchResultsForCarModel_WhenCompletionHandlerIsCreatedWithErrorStatusCode_ThenTheCompletionHandlerShouldFail() {
    let urlToCompare = "https://api.mercadolibre.com/sites/MCO/search?category=MCO1744&limit=10&offset=0&MODEL=MCO575110499"
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: urlToCompare))
      let httpResponse = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)
      return (httpResponse!, data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.searchResultsForCarModel(carResultId, withPage: 1) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .invalidResponse, "Type is not correct when status is not 200")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testSearchResultsForCarModel_WhenCompletionHandlerIsCreatedWithErrorStatusCode_ThenTheCompletionHandlerShouldThrowError() {
    let urlToCompare = "https://api.mercadolibre.com/sites/MCO/search?category=MCO1744&limit=10&offset=0&MODEL=MCO575110499"
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: urlToCompare))
      throw DCError(type: .unableToComplete, errorInfo: "Couldn't Return valid Data")
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.searchResultsForCarModel(carResultId, withPage: 1) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .unableToComplete, "Error Type is not correct when it is throwing an error")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  // MARK: LoadCarPicturesInformation Tests Methods

  func testMakeUrlForCarPicturesInformation_WhenCarIdIsPassed_ThenItShouldReturnTheCorrectURL() throws {
    let carModelId = "60259"

    let url = try dataLoader.makeUrlForCarPicturesInformation(withCarId: carModelId)

    XCTAssertEqual(url?.scheme, "https")
    XCTAssertEqual(url?.host, "api.mercadolibre.com")
    XCTAssertEqual(url?.path, "/items/60259")
  }

  func testResponseForCarPicturesInformation_WhenTheJSONFileIsLoaded_ThenTheCorrectDataShouldBeReturned() throws {
    let filename = "CarDetailsWithPictures"
    let carPictureId = "621503-MCO42790393667_072020"
    let carPictureSecureURL = "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-O.jpg"

    guard let jsonData = try dataLoader.loadJSON(fileName: filename) else {
      XCTFail("Could not get data for filename: \(filename)")
      throw DCError(type: .unableToDecode, errorInfo: "Could not get data for filename: \(filename)")
    }

    let response = try dataLoader.parseResponseForCarPicturesInformation(data: jsonData)
    let decodedFirstCarPicture = response.pictures.first
    XCTAssertEqual(carPictureId, decodedFirstCarPicture?.id, "The decoded car id: \(decodedFirstCarPicture?.id ?? "N/A") is not equal to \(carPictureId)")
    XCTAssertEqual(carPictureSecureURL, decodedFirstCarPicture?.secureUrl, "The decoded car secure URL: \(decodedFirstCarPicture?.secureUrl ?? "N/A") is not equal to \(carPictureSecureURL)")
  }

  func testLoadCarPicturesInformation_WhenTheMethodIsCalled_ThenTheCompletionHandlerIsExecuted() {
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: "https://api.mercadolibre.com/items/60259"), "the URL is incorrect")
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.loadCarPicturesInformation(withCarId: carId) { (result) in
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLoadCarPicturesInformation_WhenCompletionHandlerIsCreatedWithErrorStatusCode_ThenTheCompletionHandlerShouldFail() {
    let urlToCompare = "https://api.mercadolibre.com/items/60259"
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: urlToCompare))
      let httpResponse = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)
      return (httpResponse!, data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.loadCarPicturesInformation(withCarId: carId) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .invalidResponse, "Type is not correct when status is not 200")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testLoadCarPicturesInformation_WhenCompletionHandlerIsCreatedWithErrorStatusCode_ThenTheCompletionHandlerShouldThrowError() {
    let urlToCompare = "https://api.mercadolibre.com/items/60259"
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: urlToCompare))
      throw DCError(type: .unableToComplete, errorInfo: "Couldn't Return valid Data")
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.loadCarPicturesInformation(withCarId: carId) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .unableToComplete, "Error Type is not correct when it is throwing an error")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testDownloadImage_WhenTheMethodIsCalled_ThenTheCompletionHandlerIsExecuted() {
    let imageURLString = "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-I.jpg"
    let data: Data = try! Data(contentsOf: URL(string: imageURLString)!)
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-I.jpg"), "the URL is incorrect")
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.downloadImage(from: imageURLString) { (result) in
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testDownloadImage_WhenTheMethodIsCalledWithAnInvalidURL_ThenTheCompletionHandlerShouldFailWithInvalidURLType() {
    let imageURLString = "123 45"
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertNotEqual(request.url, URL(string: "https://api.mercadolibre.com/items/60259"), "The URL should not be valid")
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.downloadImage(from: imageURLString) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .invalidURL, "The URL is invalid so the error type should be .invalidURL")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testDownloadImage_WhenCompletionHandlerIsCreatedWithErrorStatusCode_ThenTheCompletionHandlerShouldFail() {
    let urlToCompare = "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-O.jpg"
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: urlToCompare))
      let httpResponse = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)
      return (httpResponse!, data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.downloadImage(from: urlToCompare) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .invalidResponse, "Type is not correct when status is not 200")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testDownloadImage_WhenTheMethodIsCalledWithAnInvalidURLToContructImage_ThenTheCompletionHandlerShouldFailWithUnableToCompleteType() {
    let imageURLString = "12345"
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertNotEqual(request.url, URL(string: "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-O.jpg"), "The URL should not be valid")
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.downloadImage(from: imageURLString) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .unableToComplete, "The URL is invalid to contruct an UIImage so the error type should be .unableToComplete")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testDownloadImage_WhenCompletionHandlerIsCreatedWithErrorStatusCode_ThenTheCompletionHandlerShouldThrowError() {
    let imageURLString = "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-O.jpg"
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: imageURLString))
      throw DCError(type: .unableToComplete, errorInfo: "Couldn't Return valid Data")
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.downloadImage(from: imageURLString) { (result) in
      switch result {
      case .failure(let error):
        XCTAssertEqual(error.type, .unableToComplete, "Error Type is not correct when it is throwing an error")
      default:
        XCTFail("Was expecting failure")
        break
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testDownloadImage_WhenTheMethodIsCalledWithAnImageInCache_ThenTheCompletionHandlerShouldReturnTheImageFromCache() {
    let imageURLString = "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-I.jpg"
    let cacheKey = NSString(string: imageURLString)
    let data: Data = try! Data(contentsOf: URL(string: imageURLString)!)
    let image = UIImage(data: data)
    
    DataLoader.cache.setObject(image!, forKey: cacheKey)
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: "https://mco-s1-p.mlstatic.com/621503-MCO42790393667_072020-I.jpg"), "the URL is incorrect")
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.downloadImage(from: imageURLString) { (result) in
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }
}

class MockURLProtocol: URLProtocol {
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override func startLoading() {
    guard let handler = MockURLProtocol.requestHandler else {
      XCTFail("Receive request with no handler")
      return
    }
    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
}
