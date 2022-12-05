//
//  AcronymViewModelTests.swift
//  AcromineApp
//
//  Created by Bharath Medimalli on 5/12/22.
//

import Foundation
@testable import Acromine


extension NetworkError {
    
    var urlTest: String {
        switch self {
        case .badRequest:
            return "BadRequest"
        case .badServerResponse:
            return "BadServerResponse"
        case .missingData:
            return "MissingData"
        case .emptyResult:
            return "EmptyResult"
        }
    }
    
}


class MockSession: Session {
    
    func requestData(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = request.url else { return }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            switch url.absoluteString {
            case _ where url.absoluteString.contains(NetworkError.badServerResponse(404).urlTest):
                completion(nil, HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil), nil)
                return
            case _ where url.absoluteString.contains(NetworkError.missingData.urlTest):
                completion(nil, nil, nil)
                return
            default:
                // Success case
                guard let path = Bundle(for: Self.self).path(forResource: "AcronymSample", ofType: "json") else { return }
                let localUrl = URL(fileURLWithPath: path)
                let data = try? Data(contentsOf: localUrl)
                completion(data, nil, nil)
                return
            }
        }
        
    }
    
}
