//
//  MovieDBRequest.swift
//  Example
//
//  Created by Nang Nguyen on 6/25/19.
//

import Foundation
import HttpClient

class MovieDBRequest: HTTPRequest {
    override var baseURL: URL { return URL(string: "https://api.themoviedb.org/3")! }
}
