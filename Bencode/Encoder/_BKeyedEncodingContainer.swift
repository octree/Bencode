//
//  _BKeyedEncodingContainer.swift
//  Bencode
//
//  Created by Octree on 2018/8/28.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

struct _BKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    
    typealias Key = K
    
    private let encoder: _BEncoder
    private let container: NSMutableDictionary
    private(set) public var codingPath: [CodingKey]
    
    init(referencing encoder: _BEncoder, codingPath: [CodingKey], wrapping container: NSMutableDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    mutating func encodeNil(forKey key: K) throws {
    }
    
    mutating func encode(_ value: Bool, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: String, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Double, forKey key: K) throws {
        
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Float, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Int, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Int8, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Int16, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Int32, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: Int64, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: UInt, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: UInt8, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: UInt16, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: UInt32, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode(_ value: UInt64, forKey key: K) throws {
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        
        self.encoder.codingPath.append(key)
        defer {
            self.encoder.codingPath.removeLast()
        }
        self.container[key.stringValue] = try self.encoder.box(value)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        let dictionary = NSMutableDictionary()
        self.container[key] = dictionary
        
        self.codingPath.append(key)
        defer {
            self.codingPath.removeLast()
        }
        
        let container = _BKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
    }
    
    mutating func superEncoder() -> Encoder {
        
        return _BEncoder(codingPath: [_BKey.super])
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
        
        return _BEncoder(codingPath: [key])
    }
}

