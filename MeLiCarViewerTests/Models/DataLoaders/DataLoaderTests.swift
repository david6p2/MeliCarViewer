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

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testMakeRequestForCarModel() throws {
    let carModelId = "60259"
    let page = 1
    let limit = 10
    let offset = (page - 1) * limit
    let queryParameter = "MODEL="+carModelId

    let url = try dataLoader.makeRequestForCarModel(carModelId, withPage: page)

    XCTAssertEqual(url?.scheme, "https")
    XCTAssertEqual(url?.host, "api.mercadolibre.com")
    XCTAssertEqual(url?.query, "category=MCO1744&limit=\(limit)&offset=\(offset)&\(queryParameter)")
  }

  func testParseResponseForCarModelDataResult() throws {
    let filename = "SearchByModelAndCategory"
    let carResultId = "MCO575110499"
    
    guard let jsonData = try dataLoader.loadJSON(fileName: filename) else {
      XCTFail("Could not get data for filename: \(filename)")
      throw DCError(type: .unableToDecode, errorInfo: "Could not get data for filename: \(filename)")
    }

    let response = try dataLoader.parseResponseForCarModelDataResult(data: jsonData)
    let decodedFirstCarResul = response.results.first
    XCTAssertEqual(carResultId, decodedFirstCarResul?.id, "The decoded car id: \(decodedFirstCarResul?.id ?? "N/A") is not equal to \(carResultId)")
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

class URLSessionTests: XCTestCase {
  let dataLoader = DataLoader()

  override func setUp() {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    dataLoader.defaultSession = URLSession(configuration: configuration)
  }

  func testSomeNetworkCall() {
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: "https://api.mercadolibre.com/sites/MCO/search?category=MCO1744&limit=10&offset=0&MODEL=MCO575110499"))
      return (.init(), data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.searchResultsForCarModel("MCO575110499", withPage: 1) { (result) in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
  }

  func testSomeNetworkCallWithErrorStatusCode() {
    let urlToCompare = "https://api.mercadolibre.com/sites/MCO/search?category=MCO1744&limit=10&offset=0&MODEL=MCO575110499"
    let data: Data = .init()
    MockURLProtocol.requestHandler = { request in
      XCTAssertEqual(request.url, URL(string: urlToCompare))
      let httpResponse = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)
      return (httpResponse!, data)
    }

    let expectation = XCTestExpectation(description: "response")
    dataLoader.searchResultsForCarModel("MCO575110499", withPage: 1) { (result) in
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
}
