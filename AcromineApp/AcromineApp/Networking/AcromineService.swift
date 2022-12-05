//
//  AcromineService.swift
//  AcromineApp
//
//  Created by Bharath Medimalli on 5/12/22.
//

import Foundation
enum NetworkError: Error, Equatable {
    case missingData
    case badServerResponse(Int)
    case badRequest
    case emptyResult
}

protocol Session {
    func requestData(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: Session {
    func requestData(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
}

protocol AcromineNetwork {
    var session: Session { get }
    func getModel<T: Decodable>(request: URLRequest?, completion: @escaping (Result<T, Error>) -> Void)
}

class NetworkManager: AcromineNetwork {
    var session: Session
    
    init(session: Session = URLSession.shared) {
        self.session = session
    }
    
    func getModel<T: Decodable>(request: URLRequest?, completion: @escaping (Result<T, Error>) -> Void) {
        guard let request = request else {
            completion(.failure(NetworkError.badRequest))
            return
        }
        self.session.requestData(request: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                completion(.failure(NetworkError.badServerResponse(httpResponse.statusCode)))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.missingData))
                return
            }
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }
        return
    }

}
enum NetworkParams {
    private enum NetworkConstants: String {
        case baseURL = "http://www.nactem.ac.uk/software/acromine/dictionary.py"
        case acronym = "sf"
    }
    
    // In case this app needs more functionality here, you can add it
    case acronymSearch(String)
    
    var urlRequest: URLRequest? {
        switch self {
        case .acronymSearch(let searchQuery):
            var components = URLComponents(string: NetworkConstants.baseURL.rawValue)
            components?.queryItems = [URLQueryItem(name: NetworkConstants.acronym.rawValue, value: searchQuery)]
            guard let url = components?.url else { return nil }
            return URLRequest(url: url)
        }
    }
}
