//
//  Alert.swift
//  Noyan_HW2
//
//  Created by Noyan Çepikkurt on 19.05.2023.
//

import Foundation

public enum AlertMessage: String {
    case selectCategory = "Select Category"
    case select = "Select"
    case cancel = "Cancel"
    case filterCategory = "Please select the category you want to filter"
    case offlineTitle = "The app is in offline mode"
    case offlineMessage = "You can only read the news articles in your favorites"
    case error = "Error"
    case noWebsiteUrl = "*There is no website to go*"
    case removeFavoritesTitle = "Remove from your favorites?"
    case removeFavoritesMessage = "Are you sure you want to remove this news from your favorites?"
    case removeFavoritesToast = "Removed from favorites"
    case addedFavoritesToast = "Added to your favorites"
}
