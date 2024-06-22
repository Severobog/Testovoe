//
//  SearchViewModel.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import Foundation

final class SearchViewModel {
    private var icons: [Icon] = []
    private var currentPage = 0
    private var isLoading = false
    
    var onDataChanged: (() -> Void)?
    var onErrorOccurred: ((Error) -> Void)?
    
    func searchIcons(query: String) {
        currentPage = 0
        icons.removeAll()
        loadIcons(query: query, page: currentPage, useCache: true)
    }
    
    func loadMoreIcons(query: String) {
        guard !isLoading else { return }
        currentPage += 1
        loadIcons(query: query, page: currentPage, useCache: false)
    }
    
    private func loadIcons(query: String, page: Int, useCache: Bool) {
        isLoading = true
        
        if useCache, let cachedIcons = IconManager.shared.getCachedIcons(for: query), !cachedIcons.isEmpty {
            debugPrint("Loaded \(cachedIcons.count) icons from cache for query: \(query)")
            self.icons.append(contentsOf: cachedIcons)
            self.isLoading = false
            self.onDataChanged?()
            return
        }
        
        IconManager.shared.fetchIcons(query: query, page: page) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let icons):
                debugPrint("Fetched \(icons.count) icons from API for query: \(query) on page \(page)")
                self.icons.append(contentsOf: icons)
                if useCache {
                    IconManager.shared.cacheIcons(icons, for: query)
                }
                self.onDataChanged?()
            case .failure(let error):
                debugPrint("Error fetching icons from API: \(error)")
                self.onErrorOccurred?(error)
            }
        }
    }
    
    func isFavorite(icon: Icon) -> Bool {
        return IconManager.shared.isFavorite(icon: icon)
    }
    
    func addFavorite(icon: Icon) {
        IconManager.shared.addFavorite(icon: icon)
        onDataChanged?()
    }
    
    func removeFavorite(icon: Icon) {
        IconManager.shared.removeFavorite(icon: icon)
        onDataChanged?()
    }
    
    func getIcons() -> [Icon] {
        return icons
    }

    func reloadIcons(for query: String) {
        loadIcons(query: query, page: 0, useCache: false)
    }
}
