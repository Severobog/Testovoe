//
//  IconCacheService.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import UIKit
import SQLite

final class IconCache {
    private var db: Connection!
    private let iconsTable = Table("icons")
    private let favoritesTable = Table("favorites")
    private let rasterSizesTable = Table("raster_sizes")

    private let id = Expression<Int64>("id")
    private let iconUniqueID = Expression<Int64>("icon_unique_id")
    private let query = Expression<String?>("query")
    private let imageName = Expression<String>("imageName")
    private let width = Expression<Double>("width")
    private let height = Expression<Double>("height")
    private let tags = Expression<String>("tags")
    private let largestSizeWidth = Expression<Double>("largestSizeWidth")
    private let largestSizeHeight = Expression<Double>("largestSizeHeight")

    private let rasterSizeID = Expression<Int64>("raster_size_id")
    private let sizeWidth = Expression<Double>("size_width")
    private let sizeHeight = Expression<Double>("size_height")
    private let previewURL = Expression<String>("preview_url")

    init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("icons").appendingPathExtension("sqlite3")
            db = try Connection(fileUrl.path)
            createTables()
        } catch {
            debugPrint("Error connecting to database: \(error)")
        }
    }

    private func createTables() {
        let createIconsTable = iconsTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(iconUniqueID, unique: true)
            table.column(query)
            table.column(imageName)
            table.column(width)
            table.column(height)
            table.column(tags)
            table.column(largestSizeWidth)
            table.column(largestSizeHeight)
        }

        let createFavoritesTable = favoritesTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(iconUniqueID, unique: true)
            table.column(imageName)
            table.column(width)
            table.column(height)
            table.column(tags)
            table.column(largestSizeWidth)
            table.column(largestSizeHeight)
        }

        let createRasterSizesTable = rasterSizesTable.create(ifNotExists: true) { table in
            table.column(rasterSizeID, primaryKey: .autoincrement)
            table.column(iconUniqueID)
            table.column(sizeWidth)
            table.column(sizeHeight)
            table.column(previewURL)
            table.foreignKey(iconUniqueID, references: iconsTable, iconUniqueID, delete: .cascade)
        }

        do {
            try db.run(createIconsTable)
            try db.run(createFavoritesTable)
            try db.run(createRasterSizesTable)
        } catch {
            debugPrint("Error creating tables: \(error)")
        }
    }

    // MARK: - Cache Methods

    func getIcons(for query: String) -> [Icon]? {
        do {
            let filteredIcons = iconsTable.filter(self.query == query)
            let iconRows = try db.prepare(filteredIcons)
            var icons = [Icon]()
            for iconRow in iconRows {
                let rasterSizes = getRasterSizes(for: iconRow[self.iconUniqueID])
                let icon = Icon(
                    iconUniqueID: iconRow[self.iconUniqueID],
                    imageName: iconRow[self.imageName],
                    size: CGSize(width: iconRow[self.width], height: iconRow[self.height]),
                    tags: iconRow[self.tags].components(separatedBy: ","),
                    largestSize: CGSize(width: iconRow[self.largestSizeWidth], height: iconRow[self.largestSizeHeight]),
                    rasterSizes: rasterSizes
                )
                icons.append(icon)
            }
            return icons
        } catch {
            debugPrint("Error fetching icons: \(error)")
            return nil
        }
    }

    private func getRasterSizes(for iconID: Int64) -> [RasterSize] {
        do {
            let filteredRasterSizes = rasterSizesTable.filter(self.iconUniqueID == iconID)
            let rasterSizeRows = try db.prepare(filteredRasterSizes)
            var rasterSizes = [RasterSize]()
            for rasterSizeRow in rasterSizeRows {
                let rasterSize = RasterSize(
                    sizeWidth: CGFloat(rasterSizeRow[self.sizeWidth]),
                    sizeHeight: CGFloat(rasterSizeRow[self.sizeHeight]),
                    formats: [Format(previewURL: rasterSizeRow[self.previewURL])]
                )
                rasterSizes.append(rasterSize)
            }
            return rasterSizes
        } catch {
            debugPrint("Error fetching raster sizes: \(error)")
            return []
        }
    }

    func cache(icons: [Icon], for query: String) {
        do {
            let deleteQuery = iconsTable.filter(self.query == query).delete()
            try db.run(deleteQuery)
            
            for icon in icons {
                let tagsString = icon.tags.joined(separator: ",")
                let insertIcon = iconsTable.insert(
                    self.iconUniqueID <- icon.iconUniqueID,
                    self.query <- query,
                    self.imageName <- icon.imageName,
                    self.width <- Double(icon.size.width),
                    self.height <- Double(icon.size.height),
                    self.tags <- tagsString,
                    self.largestSizeWidth <- Double(icon.largestSize.width),
                    self.largestSizeHeight <- Double(icon.largestSize.height)
                )
                try db.run(insertIcon)
                
                for rasterSize in icon.rasterSizes {
                    let insertRasterSize = rasterSizesTable.insert(
                        self.iconUniqueID <- icon.iconUniqueID,
                        self.sizeWidth <- Double(rasterSize.sizeWidth),
                        self.sizeHeight <- Double(rasterSize.sizeHeight),
                        self.previewURL <- rasterSize.formats.first?.previewURL ?? ""
                    )
                    try db.run(insertRasterSize)
                }
            }
        } catch {
            debugPrint("Error caching icons: \(error)")
        }
    }

    func getImage(for url: String) -> UIImage? {
        guard let url = URL(string: url) else { return nil }
        let fileManager = FileManager.default
        let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileUrl = documentDirectory?.appendingPathComponent(url.lastPathComponent).appendingPathExtension("png")
        if let fileUrl = fileUrl, let imageData = try? Data(contentsOf: fileUrl), let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }

    func cache(image: UIImage, for url: String) {
        guard let url = URL(string: url) else { return }
        let fileManager = FileManager.default
        let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileUrl = documentDirectory?.appendingPathComponent(url.lastPathComponent).appendingPathExtension("png")
        if let fileUrl = fileUrl, let imageData = image.pngData() {
            try? imageData.write(to: fileUrl)
        }
    }

    // MARK: - Favorite Methods

    func addFavorite(icon: Icon) {
        do {
            let tagsString = icon.tags.joined(separator: ",")
            let insertFavorite = favoritesTable.insert(
                self.iconUniqueID <- icon.iconUniqueID,
                self.imageName <- icon.imageName,
                self.width <- Double(icon.size.width),
                self.height <- Double(icon.size.height),
                self.tags <- tagsString,
                self.largestSizeWidth <- Double(icon.largestSize.width),
                self.largestSizeHeight <- Double(icon.largestSize.height)
            )
            try db.run(insertFavorite)

            for rasterSize in icon.rasterSizes {
                let insertRasterSize = rasterSizesTable.insert(
                    self.iconUniqueID <- icon.iconUniqueID,
                    self.sizeWidth <- Double(rasterSize.sizeWidth),
                    self.sizeHeight <- Double(rasterSize.sizeHeight),
                    self.previewURL <- rasterSize.formats.first?.previewURL ?? ""
                )
                try db.run(insertRasterSize)
            }
        } catch {
            debugPrint("Error adding favorite: \(error)")
        }
    }

    func removeFavorite(icon: Icon) {
        do {
            let favorite = favoritesTable.filter(self.iconUniqueID == icon.iconUniqueID)
            try db.run(favorite.delete())
            
            let rasterSizes = rasterSizesTable.filter(self.iconUniqueID == icon.iconUniqueID)
            try db.run(rasterSizes.delete())
        } catch {
            debugPrint("Error removing favorite: \(error)")
        }
    }

    func getFavorites() -> [Icon] {
        do {
            let favoriteRows = try db.prepare(favoritesTable)
            var favorites = [Icon]()
            for row in favoriteRows {
                let rasterSizes = getRasterSizes(for: row[self.iconUniqueID])
                let icon = Icon(
                    iconUniqueID: row[self.iconUniqueID],
                    imageName: row[self.imageName],
                    size: CGSize(width: row[self.width], height: row[self.height]),
                    tags: row[self.tags].components(separatedBy: ","),
                    largestSize: CGSize(width: row[self.largestSizeWidth], height: row[self.largestSizeHeight]),
                    rasterSizes: rasterSizes
                )
                favorites.append(icon)
            }
            return favorites
        } catch {
            debugPrint("Error fetching favorites: \(error)")
            return []
        }
    }
}
