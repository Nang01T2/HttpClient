//
//  Genres.swift
//  Example
//
//  Created by Nang Nguyen on 6/25/19.
//

import Foundation
import HttpClient
import Moya

// MARK: - Genres
struct Genres: Codable {
    let genres: [Genre]
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

extension Genres: Parceable {
    
    static func parseResponse(_ response: Response) -> Result<Genres, Error> {
        do {
            let data = try response.data.decoded() as Genres
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
    
}
