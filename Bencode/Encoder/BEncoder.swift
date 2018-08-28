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


class _BEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var storage: _BEncodingStorage = _BEncodingStorage()
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var canEncodeNewValue: Bool {
        return self.storage.count == self.codingPath.count
    }
    
    init(codingPath: [CodingKey] = []) {
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {

        let topContainer: NSMutableDictionary
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        let container = _BKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        
    }

    func singleValueContainer() -> SingleValueEncodingContainer {

    }
}

protocol BDictionaryEncodableMarker { }

extension Dictionary : BDictionaryEncodableMarker where Key == String, Value: Encodable { }


extension _BEncoder {
    
    func box(_ value: Bool)   -> BencodeValue { return .integer(value ? 1 : 0) }
    func box(_ value: Int)    -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: Int8)   -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: Int16)  -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: Int32)  -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: Int64)  -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: UInt)   -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: UInt8)  -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: UInt16) -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: UInt32) -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: UInt64) -> BencodeValue { return .integer(Int(value)) }
    func box(_ value: String) -> BencodeValue { return .string(value) }
    
    func box(_ float: Float) -> BencodeValue {
        
        return .integer(Int(float))
    }
    
    func box(_ double: Double) -> BencodeValue {
        return .integer(Int(double))
    }
    
    func box(_ data: Data) throws -> BencodeValue {
        return .string(String(data: data, encoding: .utf8)!)
    }
    
    func box(_ dict: [String : Encodable]) throws -> BencodeValue? {
        
        let depth = self.storage.count
        let result = self.storage.pushKeyedContainer()
        do {
            for (key, value) in dict {
                self.codingPath.append(_BKey(stringValue: key, intValue: nil))
                defer { self.codingPath.removeLast() }
                result[key] = try box(value)
            }
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                let _ = self.storage.pop()
            }
            throw error
        }
        
        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }
        
        return .dict(self.storage.pop() as! [String: BencodeValue])
    }
    
    func box(_ value: Encodable) throws -> BencodeValue {
        
        return try self.box_(value) ?? .dict([:])
    }
    
    fileprivate func box_(_ value: Encodable) throws -> BencodeValue? {
        
        let type = Swift.type(of: value)
        if type == Data.self || type == NSData.self {
            return try self.box((value as! Data))
        } else if type == URL.self || type == NSURL.self {
            return self.box((value as! URL).absoluteString)
        } else if value is BDictionaryEncodableMarker {
            return try self.box(value as! [String : Encodable])
        }
        
        let depth = self.storage.count
        do {
            try value.encode(to: self)
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                let _ = self.storage.pop()
            }
            
            throw error
        }
        
        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }
        
        return .dict(self.storage.pop() as! [String: BencodeValue])
        
    }
}
