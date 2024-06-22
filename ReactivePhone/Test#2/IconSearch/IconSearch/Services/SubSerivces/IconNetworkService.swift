//
//  IconService.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import Foundation
import UIKit

final class IconNetworkService {
    private let apiKey = "wrTsh5UdQO6f8sfTpaUghPCSkfXlZ0PAk0WuO5ZGbhBoMrPPPIXh4Ohi3SYsBD3t"
    private let baseURL = "https://api.iconfinder.com/v4/icons/search"
    
    func searchIcons(query: String, page: Int, completion: @escaping (Result<[Icon], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            }
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "count", value: "20"),
            URLQueryItem(name: "offset", value: "\(page * 20)")
        ]
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    debugPrint("Request failed with error: \(error)")
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    debugPrint("No data received from request")
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(IconResponse.self, from: data)
                let icons = response.icons.compactMap { iconData -> Icon? in
                    guard let largestRaster = iconData.raster_sizes.max(by: { $0.size_width < $1.size_width }) else {
                        return nil
                    }
                    
                    let uniqueIDString = "\(iconData.tags.joined())\(largestRaster.size_width)\(largestRaster.size_height)\(largestRaster.formats.first?.preview_url ?? "")"
                    let iconUniqueID = Int64(uniqueIDString.hashValue)
                    
                    return Icon(
                        iconUniqueID: iconUniqueID,
                        imageName: largestRaster.formats.first?.preview_url ?? "",
                        size: CGSize(width: largestRaster.size_width, height: largestRaster.size_height),
                        tags: iconData.tags,
                        largestSize: CGSize(width: largestRaster.size_width, height: largestRaster.size_height),
                        rasterSizes: iconData.raster_sizes.map { RasterSize(sizeWidth: $0.size_width, sizeHeight: $0.size_height, formats: $0.formats.map { Format(previewURL: $0.preview_url) }) }
                    )
                }
                DispatchQueue.main.async {
                    debugPrint("Request succeeded with \(icons.count) icons")
                    completion(.success(icons))
                }
            } catch {
                DispatchQueue.main.async {
                    debugPrint("Failed to decode response: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func loadImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            completion(image)
        }.resume()
    }
}
