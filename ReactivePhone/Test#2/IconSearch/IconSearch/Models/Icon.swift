//
//  Icon.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import UIKit

struct Icon {
    let iconUniqueID: Int64
    let imageName: String
    let size: CGSize
    let tags: [String]
    let largestSize: CGSize
    let rasterSizes: [RasterSize]
}


struct RasterSize: Codable {
    let sizeWidth: CGFloat
    let sizeHeight: CGFloat
    let formats: [Format]

    enum CodingKeys: String, CodingKey {
        case sizeWidth = "size_width"
        case sizeHeight = "size_height"
        case formats
    }
}

struct Format: Codable {
    let previewURL: String

    enum CodingKeys: String, CodingKey {
        case previewURL = "preview_url"
    }
}

