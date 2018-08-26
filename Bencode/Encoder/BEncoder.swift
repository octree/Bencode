//
//  BEncoder.swift
//  Bencode
//
//  Created by Octree on 2018/8/26.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

open class BEncoder {
    
    public init() {}
    
    open func encode<T: Encodable>(_ value: T) throws -> Data {
        
//        let encoder =
        return Data()
    }
    
    
}


//class _BEncoder: Encoder {
//    var codingPath: [CodingKey] = []
//
//    var userInfo: [CodingUserInfoKey : Any] = [:]
//
//    init() {
//    }
//
//    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//
//    }
//
//    func unkeyedContainer() -> UnkeyedEncodingContainer {
//
//    }
//
//    func singleValueContainer() -> SingleValueEncodingContainer {
//
//    }
//}


