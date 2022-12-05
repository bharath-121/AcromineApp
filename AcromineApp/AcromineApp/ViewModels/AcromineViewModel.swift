//
//  AcromineViewModel.swift
//  AcromineApp
//
//  Created by Bharath Medimalli on 5/12/22.
//

import Foundation

class AcromineViewModel {
    
    var result: AcromineResponseModel? = nil
    var network: AcromineNetwork
    
    init(network: AcromineNetwork) {
        self.network = network
    }
    
    func searchAcronym(acronym: String, completionHandler: @escaping(Error?) -> Void) {

        guard !acronym.isEmpty else {
            self.result = nil
            return
        }
        
        self.network.getModel(request: NetworkParams.acronymSearch(acronym).urlRequest) { [weak self] (result: Result<[AcromineResponseModel], Error>) in
                switch result {
                case .success(let result):
                    if let value = result.first {
                        self?.result = value
                        completionHandler(nil)
                    } else {
                        self?.result = nil
                        completionHandler(NetworkError.emptyResult)
                    }
                case .failure(let error):
                    completionHandler(error)
                }
            }
    }
    
    var count: Int {
        return self.result?.lfs.count ?? 0
    }
    
    func acronymText(for index: Int) -> String? {
        guard index < (self.result?.lfs.count ?? 0) else { return nil }
        return self.result?.lfs[index].lf
    }

}
