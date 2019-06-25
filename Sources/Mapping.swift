//
//  Mapping.swift
//  DevKit
//
//  Created by Nang Nguyen on 3/29/19.
//

import Foundation

public typealias MappingFunction<InputType,OutputType> = ( _ input: InputType) -> (OutputType)

public class Mapping<InputValue,OutputValue>: NSObject {
    
    private var mappingClosure : MappingFunction<InputValue,OutputValue>
    
    public init(_ mapping: @escaping (InputValue) -> (OutputValue)) {
        self.mappingClosure = mapping
    }
    
    public func map(_ input: InputValue) -> (OutputValue) {
        return self.mappingClosure(input)
    }
}
