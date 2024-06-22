//
//  FavoritesViewModel.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import Foundation

final class FavoritesViewModel {
    
    var onDataChanged: (() -> Void)?
    
    func loadFavorites() {
        IconManager.shared.loadFavorites()
        onDataChanged?()
    }
    
    func getFavorites() -> [Icon] {
        return IconManager.shared.getFavorites()
    }
    
    func removeFavorite(icon: Icon) {
        IconManager.shared.removeFavorite(icon: icon)
        onDataChanged?()
    }
    
    func addFavorite(icon: Icon) {
        IconManager.shared.addFavorite(icon: icon)
        onDataChanged?()
    }
    
    func saveIconToGallery(icon: Icon) {
        IconManager.shared.saveIconToGallery(icon: icon)
    }
}
