//
//  PopularMoviesRequest.swift
//  Example
//
//  Created by Nang Nguyen on 6/25/19.
//

import HttpClient
import Moya

class PopularMoviesRequest: MovieDBRequest {
    override var path: String { return "/movie/popular" }
    
    override var method: Moya.Method {
        return .get
    }
    
    override var task: Task {
        return .requestParameters(parameters: ["api_key": "c8af413a566d17e21c265a689a0312ca",
                                               "page": page],
                                  encoding: URLEncoding.queryString)
    }
    
    override var validationType: ValidationType {
        return .successCodes
    }
    
    private let page: Int
    
    init(page: Int) {
        self.page = page
        super.init()
    }
}
