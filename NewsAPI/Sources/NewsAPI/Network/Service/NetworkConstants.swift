//
//  NetworkConstants.swift
//  
//
//  Created by Noyan Çepikkurt on 11.05.2023.
//

import Foundation

public enum NetworkExchangeURL: String {
    case usdURL = "https://api.exchangerate.host/convert?from=USD&to=TRY"
    case euroURL = "https://api.exchangerate.host/convert?from=EUR&to=TRY"
}

public enum NetworkAPIConstantsWeather: String {
    case baseURL = "https://api.openweathermap.org/data/2.5/weather?"
    case APIKEYWeather = "f137cd7dc8736f2bde7dc03efeae123d"
}

enum NetworkAPIConstantsNews: String {
    case baseURL = "https://api.nytimes.com/svc/topstories/v2/"
    case APIKEYNews = "faZR5Xae70i6feQPpThPhxRY1JVG1z8n"
    case endPoint = ".json?api-key="
}

public enum NetworkConstants: String, CaseIterable {
    case arts = "arts"
    case automobiles = "automobiles"
    case books = "books"
    case business = "business"
    case fashion = "fashion"
    case food = "food"
    case health = "health"
    case home = "home"
    case insider = "insider"
    case magazine = "magazine"
    case movies = "movies"
    case nyregion = "nyregion"
    case obituaries = "obituaries"
    case opinion = "opinion"
    case realestate = "realestate"
    case science = "science"
    case sports = "sports"
    case sundayreview = "sundayreview"
    case technology = "technology"
    case theater = "theater"
    case tmagazine = "t-magazine"
    case travel = "travel"
    case upshot = "upshot"
    case us = "us"
    case world = "world"
    
    public var pathUrlNews: String {
        NetworkAPIConstantsNews.baseURL.rawValue + self.rawValue + NetworkAPIConstantsNews.endPoint.rawValue + NetworkAPIConstantsNews.APIKEYNews.rawValue
    }
    
    public var pathUrlExchange: String {
        "https://api.exchangerate.host/convert?from=USD&to=TRY"
    }
}


