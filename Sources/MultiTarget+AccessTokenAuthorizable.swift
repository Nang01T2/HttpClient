//
//  MultiTarget+Extensions.swift
//  DevKit
//
//  Created by Nang Nguyen on 3/31/19.
//

import Moya

extension MultiTarget: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType {
        if target is AccessTokenAuthorizable {
            guard let authTarget = target as? AccessTokenAuthorizable else {
                return .none
            }
            return authTarget.authorizationType
        }
        return .none
    }
}
