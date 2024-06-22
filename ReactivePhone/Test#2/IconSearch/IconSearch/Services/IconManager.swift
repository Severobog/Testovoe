//
//  IconManager.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import Foundation
import UIKit

final class IconManager {
    static let shared = IconManager()
    private let iconCache = IconCache()
    private var favorites: [Icon] = []
    private let maxFavorites = 5
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Cache Methods
    func getCachedIcons(for query: String) -> [Icon]? {
        return iconCache.getIcons(for: query)
    }
    
    func cacheIcons(_ icons: [Icon], for query: String) {
        iconCache.cache(icons: icons, for: query)
    }
    
    func getCachedImage(for url: String) -> UIImage? {
        return iconCache.getImage(for: url)
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        iconCache.cache(image: image, for: url)
    }
    
    // MARK: - Network Methods
    func fetchIcons(query: String, page: Int, completion: @escaping (Result<[Icon], Error>) -> Void) {
        IconNetworkService().searchIcons(query: query, page: page, completion: completion)
    }
    
    func loadIcon(for url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = getCachedImage(for: url) {
            completion(cachedImage)
        } else {
            IconNetworkService().loadImage(for: url) { [weak self] image in
                guard let image = image else {
                    completion(nil)
                    return
                }

                self?.cacheImage(image, for: url)
                completion(image)
            }
        }
    }
    
    // MARK: - Favorite Methods
    func loadFavorites() {
        favorites = iconCache.getFavorites()
    }
    
    func getFavorites() -> [Icon] {
        return favorites
    }
    
    func addFavorite(icon: Icon) {
        if favorites.count >= maxFavorites {
            if let oldestIcon = favorites.first {
                removeFavorite(icon: oldestIcon)
                notifySearchViewController(icon: oldestIcon)
            }
        }
        favorites.append(icon)
        iconCache.addFavorite(icon: icon)
    }
    
    func removeFavorite(icon: Icon) {
        if let index = favorites.firstIndex(where: { $0.iconUniqueID == icon.iconUniqueID }) {
            favorites.remove(at: index)
            iconCache.removeFavorite(icon: icon)
        }
    }
    
    func toggleFavorite(icon: Icon) {
        if isFavorite(icon: icon) {
            removeFavorite(icon: icon)
        } else {
            addFavorite(icon: icon)
        }
    }
    
    func isFavorite(icon: Icon) -> Bool {
        return favorites.contains(where: { $0.iconUniqueID == icon.iconUniqueID })
    }
    
    // MARK: - Save to Gallery
    func saveIconToGallery(icon: Icon) {
        print(icon)
        guard let largestRaster = icon.rasterSizes.max(by: { $0.sizeWidth < $1.sizeWidth }),
              let urlString = largestRaster.formats.first?.previewURL,
              let url = URL(string: urlString) else {
            print("Invalid URL or raster size not found")
            return
        }

        print("Downloading image from URL: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Error creating image from data")
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("Image saved to gallery")
        }.resume()
    }


    
    private func notifySearchViewController(icon: Icon) {
        NotificationCenter.default.post(name: NSNotification.Name("FavoriteRemoved"), object: icon)
    }
}
