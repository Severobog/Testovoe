//
//  IconResoponse.swift
//  IconSearch
//
//  Created by Демид Стариков on 23.06.2024.
//

import Foundation

struct IconResponse: Codable {
    let icons: [IconData]
}

struct IconData: Codable {
    let raster_sizes: [RasterSizeData]
    let tags: [String]
}

struct RasterSizeData: Codable {
    let size_width: CGFloat
    let size_height: CGFloat
    let formats: [FormatData]
}

struct FormatData: Codable {
    let preview_url: String
}
