//
//  Images.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 19.05.2023.
//

import Foundation

public enum WeatherIcons: String {
    case clearSky = "01d"
    case fewClouds = "02d"
    case scatteredClouds = "03d"
    case brokenClouds = "04d"
    case showerRain = "09d"
    case rain = "10d"
    case thunderStorm = "11d"
    case snow = "13d"
    case mist = "50d"
}

public enum SideMenuIcons: String {
    case sideMenuClose = "line.3.horizontal"
    case sideMenuOpen = "menu"
}

public enum FavoriteIcons: String {
    case favorite = "star.fill"
    case notFavorite = "star"
}

public enum ExchangeRateIcon: String {
    case increase = "increase"
    case decrease =  "decrease"
}
