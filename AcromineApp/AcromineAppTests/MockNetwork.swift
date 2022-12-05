//
//  AcronymViewModelTests.swift
//  AcromineApp
//
//  Created by Bharath Medimalli on 5/12/22.
//

import Foundation
@testable import Acromine

class MockNetworkManager: AcromineNetwork {
    
    var session: Session
    
    init(session: Session = MockSession()) {
        self.session = session
    }
    
    func getModel<T>(request: URLRequest?, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        
        guard let url = request?.url else {
            completion(.failure(NetworkError.badRequest))
            return
        }
        
        switch url.absoluteString {
        case _ where url.absoluteString.contains(NetworkError.emptyResult.urlTest):
            guard let model = [] as? T else { return }
            completion(.success(model))
            return
        case _ where url.absoluteString.contains(NetworkError.badRequest.urlTest):
            completion(.failure(NetworkError.badRequest))
            return
        default:
            guard let model = [AcromineResponseModel(sf: "DOE", lfs: [SpecificAcronym(lf: "Department of Energy", freq: 5, since: 1981, variations: [Variation(lf: "", freq: 0, since: 0)])])] as? T else { return }
            completion(.success(model))
            return
        }
        
    }
    
}
