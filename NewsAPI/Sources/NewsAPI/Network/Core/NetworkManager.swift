//
//  NetworkManager.swift
//  
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import Foundation
import Alamofire

final public class NetworkManager {
    static public let shared = NetworkManager()
    
    func request<T: Codable>(pathUrl: String, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(pathUrl, encoding: JSONEncoding.default).validate().responseDecodable(of: T.self){ response in
            switch response.result {
            case .success(let model):
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
