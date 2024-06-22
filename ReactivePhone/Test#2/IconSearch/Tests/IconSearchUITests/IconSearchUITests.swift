//
//  IconSearchUITests.swift
//  IconSearchUITests
//
//  Created by Демид Стариков on 22.06.2024.
//

import XCTest

class IconSearchUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testTabBarNavigationToFavorites() throws {
        let favoritesTab = app.tabBars.buttons["Favorites"]
        favoritesTab.tap()
        
        let favoritesTable = app.tables["favoritesTableView"]
        XCTAssertTrue(favoritesTable.exists, "Favorites table view should exist after tapping on Favorites tab")
    }
    
    func testSearchButtonExists() throws {
        app.tabBars.buttons["Search"].tap()
        
        let searchButton = app.buttons["searchButton"]
        XCTAssertTrue(searchButton.exists, "Search button should exist on the search screen")
        
        let searchTable = app.tables["searchTableView"]
        XCTAssertTrue(searchTable.exists, "Search table view should exist on the search screen")
    }
}
