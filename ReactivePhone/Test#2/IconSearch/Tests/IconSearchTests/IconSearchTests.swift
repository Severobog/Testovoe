//
//  IconSearchTests.swift
//  IconSearchTests
//
//  Created by Демид Стариков on 22.06.2024.
//

import XCTest
@testable import IconSearch

final class IconManagerTests: XCTestCase {

    var iconManager: IconManager!
    var testIcon: Icon!

    override func setUpWithError() throws {
        iconManager = IconManager.shared
        iconManager.loadFavorites()

        testIcon = Icon(
            iconUniqueID: 123, imageName: "https://example.com/icon.png",
            size: CGSize(width: 64, height: 64),
            tags: ["example", "icon"],
            largestSize: CGSize(width: 64, height: 64),
            rasterSizes: [RasterSize(sizeWidth: 64, sizeHeight: 64, formats: [Format(previewURL: "https://example.com/icon.png")])]
        )
    }

    override func tearDownWithError() throws {
        iconManager = nil
        testIcon = nil
    }

    func testAddFavorite() throws {
        iconManager.addFavorite(icon: testIcon)
        XCTAssertTrue(iconManager.isFavorite(icon: testIcon), "The icon should be added to favorites.")
    }

    func testRemoveFavorite() throws {
        iconManager.addFavorite(icon: testIcon)
        iconManager.removeFavorite(icon: testIcon)
        XCTAssertFalse(iconManager.isFavorite(icon: testIcon), "The icon should be removed from favorites.")
    }

    func testFavoriteLimit() throws {
        for i in 1...6 {
            let icon = Icon(
                iconUniqueID: Int64(i), imageName: "https://example.com/icon\(i).png",
                size: CGSize(width: 64, height: 64),
                tags: ["example", "icon"],
                largestSize: CGSize(width: 64, height: 64),
                rasterSizes: [RasterSize(sizeWidth: 64, sizeHeight: 64, formats: [Format(previewURL: "https://example.com/icon\(i).png")])]
            )
            iconManager.addFavorite(icon: icon)
        }
        XCTAssertEqual(iconManager.getFavorites().count, 5, "The number of favorites should be limited to 5.")
        XCTAssertFalse(iconManager.isFavorite(icon: Icon(
            iconUniqueID: 1, imageName: "https://example.com/icon1.png",
            size: CGSize(width: 64, height: 64),
            tags: ["example", "icon"],
            largestSize: CGSize(width: 64, height: 64),
            rasterSizes: [RasterSize(sizeWidth: 64, sizeHeight: 64, formats: [Format(previewURL: "https://example.com/icon1.png")])]
        )), "The oldest icon should be removed from favorites.")
    }
}
