//
//  HTTPRequest.swift
//  DevKit
//
//  Created by Nang Nguyen on 3/30/19.
//

import Foundation
import Moya

public protocol HTTPRequestProtocol: TargetType, AccessTokenAuthorizable {}

open class HTTPRequest : HTTPRequestProtocol {
    
    open var path: String {
        return "/"
    }
    
    open var baseURL: URL {
        return URL(string: "Override Me")!
    }
    
    open var method: Moya.Method {
        return .get
    }
    
    open var task: Moya.Task {
        return .requestPlain
    }
    
    open var sampleData: Data {
        return Data()
    }
    
    open var headers: [String: String]? {
        return nil
    }
    
    open var authorizationType: AuthorizationType {
        return .none
    }
    
    open var validationType: ValidationType {
        return .none
    }
    
    public init() {}
}
