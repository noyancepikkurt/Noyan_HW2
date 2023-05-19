//
//  ExchangeModel.swift
//  
//
//  Created by Noyan Çepikkurt on 15.05.2023.
//

import Foundation

public struct ExchangeModel: Codable {
    public let motd: MOTD?
    public let success: Bool?
    public let query: Query?
    public let info: Info?
    public let historical: Bool?
    public let date: String?
    public let result: Double?
}

public struct Info: Codable {
    public let rate: Double?
}


public struct MOTD: Codable {
    public let msg: String?
    public let url: String?
}


public struct Query: Codable {
    public let from, to: String?
    public let amount: Int?
}

