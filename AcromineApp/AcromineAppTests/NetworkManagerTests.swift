//
//  AcronymViewModelTests.swift
//  AcromineApp
//
//  Created by Bharath Medimalli on 5/12/22.
//

import XCTest
@testable import Acromine

class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.networkManager = NetworkManager(session: MockSession())
    }

    override func tearDownWithError() throws {
        self.networkManager = nil
        try super.tearDownWithError()
    }

    func testSuccessfullRequest() {
        let expectation = XCTestExpectation(description: "Successfullly got and decoded data")
        var acronym: [AcromineResponseModel]?
        
        self.networkManager.getModel(request: NetworkParams.acronymSearch("TEST").urlRequest) { (result: Result<[AcromineResponseModel], Error>) in
            switch result {
            case .success(let value):
                acronym = value
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 3)
        
        XCTAssertEqual(acronym?.first?.lfs.count, 6)
        XCTAssertEqual(acronym?.first?.lfs.first?.lf, "Department of Energy")
    }
    
    func testBadRequestFailureRequest() {
        let expectation = XCTestExpectation(description: "Received a Bad Request Failure")
        var networkError: NetworkError?
        
        self.networkManager.getModel(request: nil) { (result: Result<[AcromineResponseModel], Error>) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                networkError = error as? NetworkError
                expectation.fulfill()
            }
        }
        
        XCTAssertEqual(networkError, NetworkError.badRequest)
    }
    
    func testMissingDataFailureRequest() {
        let expectation = XCTestExpectation(description: "Received a Missing Data Failure")
        var networkError: NetworkError?
        
        guard let url = URL(string: NetworkError.missingData.urlTest) else {
            XCTFail()
            return
        }
        
        self.networkManager.getModel(request: URLRequest(url: url)) { (result: Result<[AcromineResponseModel], Error>) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                networkError = error as? NetworkError
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3)
        
        XCTAssertEqual(networkError, NetworkError.missingData)
    }
    
    func testBadServerResponseFailureRequest() {
        let expectation = XCTestExpectation(description: "Received a Bad Server Response Failure")
        var networkError: NetworkError?
        
        guard let url = URL(string: NetworkError.badServerResponse(404).urlTest) else {
            XCTFail()
            return
        }
        
        self.networkManager.getModel(request: URLRequest(url: url)) { (result: Result<[AcromineResponseModel], Error>) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                networkError = error as? NetworkError
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(networkError, NetworkError.badServerResponse(404))
    }

}
