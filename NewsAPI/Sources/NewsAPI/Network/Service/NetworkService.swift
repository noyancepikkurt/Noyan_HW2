//
//  NetworkService.swift
//  
//
//  Created by Noyan Çepikkurt on 10.05.2023.
//

import Foundation

public protocol NetworkServiceProtocol: AnyObject {
    func fetchNews(pathUrl: String, completion: @escaping (Result<[News]?, Error>) -> Void)
    func fetchWeather(pathUrl: String, completion: @escaping (Result<Weather?, Error>) -> Void)
    func fetchExchange(pathUrl: String, completion: @escaping (Result<ExchangeModel?, Error>) -> Void)
}

final public class NetworkService: NetworkServiceProtocol {
    static public let shared = NetworkService()
    
    public func fetchExchange(pathUrl: String, completion: @escaping (Result<ExchangeModel?, Error>) -> Void) {
        NetworkManager.shared.request(pathUrl: pathUrl) { (result: Result<ExchangeModel, Error>) in
            switch result {
            case .success(let success):
                let usd = success
                completion(.success(usd))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    public func fetchWeather(pathUrl: String, completion: @escaping (Result<Weather?, Error>) -> Void) {
        NetworkManager.shared.request(pathUrl: pathUrl) { (result: Result<Weather, Error>) in
            switch result {
            case .success(let success):
                let weatherArray = success
                completion(.success(weatherArray))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    public func fetchNews(pathUrl: String, completion: @escaping (Result<[News]?, Error>) -> Void) {
        NetworkManager.shared.request(pathUrl: pathUrl) { (result: Result<NewsModel, Error>) in
            switch result {
            case .success(let success):
                let news = success.results
                completion(.success(news))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}


