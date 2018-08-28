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

        let encoder = _BEncoder()
        guard let topLevel = try encoder.box_(value) else {
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }
        return topLevel.data
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
        
        let topContainer: NSMutableArray
        if self.canEncodeNewValue {
            topContainer = self.storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableArray else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        return _BUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {

        return self
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
        
        let value = self.storage.pop()
        if value is NSMutableDictionary {
            
            return .dict(value as! [String: BencodeValue])
        } else if value is NSMutableArray {
            
            return .list(value as! [BencodeValue])
        } else {
            
            return value as? BencodeValue
        }
    }
}


extension _BEncoder: SingleValueEncodingContainer {
    
    fileprivate func assertCanEncodeNewValue() {
        precondition(self.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    func encodeNil() throws {
        assertCanEncodeNewValue()
    }
    
    func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: String) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Double) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Float) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Int) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Int8) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Int16) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Int32) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: Int64) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: UInt) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: UInt8) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: UInt16) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: UInt32) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode(_ value: UInt64) throws {
        
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        
        assertCanEncodeNewValue()
        self.storage.push(container: try self.box(value))
    }
    
    
}
