//
//  GenresRequest.swift
//  Example
//
//  Created by Nang Nguyen on 6/25/19.
//

import HttpClient
import Moya

class GenresRequest: MovieDBRequest {
    
    override var path: String { return "/genre/movie/list" }
    
    override var method: Moya.Method {
        return .get
    }
    
    override var task: Task {
        return .requestParameters(parameters: parameters,
                                  encoding: URLEncoding.queryString)
    }
    
    override var validationType: ValidationType {
        return .successCodes
    }
    
    var parameters: [String: Any] {
        return ["api_key": "c8af413a566d17e21c265a689a0312ca"]
    }
    
}
