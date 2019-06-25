//
//  TargetTypeMapping.swift
//  DevKit
//
//  Created by Nang Nguyen on 3/30/19.
//

import Foundation
import Moya

public typealias MoyaMapping<OutputType> = Mapping<Result<Moya.Response, MoyaError>,OutputType>

public protocol TargetTypeMapping {
    associatedtype T
    var mapping: Mapping<Result<Moya.Response, MoyaError>,T> { get }
}

public protocol Parceable {
    static func parseResponse(_ response: Response) -> HTTPResult<Self>
}
