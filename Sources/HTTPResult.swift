//
//  HTTPResult.swift
//  DevKit
//
//  Created by Nang Nguyen on 3/30/19.
//

import Moya

public typealias HTTPResult<T> = Result<T, Error>

public extension Result {
    var value: Success? {
        do {
            return try self.get()
        } catch {
            return nil
        }
    }
}

public extension Result where Success == Response {
    func decode<T: Decodable>(with decoder: AnyDecoder = JSONDecoder()) -> HTTPResult<T> {
        do {
            let response = try get()
            let decoded = try response.data.decoded(using: decoder) as T
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
}
