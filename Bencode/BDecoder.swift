//
//  BDecoder.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

open class BDecoder {

    open var userInfo: [CodingUserInfoKey : Any] = [:]

    public init() {}
    
    open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let topLevel: BencodeValue
        var bytes = [UInt8](data)
        switch BencodeParser.parse(bytes[...]) {
        case let .done(_, rt):
            topLevel = rt
        case let .fail(error):
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid Becode.", underlyingError: error))
        }
        
        let decoder = _BDecoder(referencing: topLevel)
        guard let value = try decoder.unbox(topLevel, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }
        
        return value
    }
}




internal class _BDecoder: Decoder {
    public var codingPath: [CodingKey]
    private var storage: _BDecodingStorage
    
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    init(referencing container: BencodeValue, at codingPath: [CodingKey] = []) {
        self.storage = _BDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard case let .dict(topContainer) = self.storage.topContainer else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: self.storage.topContainer)
        }
        
        let container = _BKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container);
    }
    
    
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard case let .list(topContainer) = self.storage.topContainer else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: self.storage.topContainer)
        }
        
        return _BUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        
        return self
    }
}


extension _BDecoder {
    
    func unbox(_ value: BencodeValue, as type: Bool.Type) throws -> Bool? {
        
        if case let .integer(number) = value {
            
            return number != 0
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }
    
    func unbox(_ value: BencodeValue, as type: Int.Type) throws -> Int? {
        
        if case let .integer(number) = value {
            return number
        }
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }
    
    func unbox(_ value: BencodeValue, as type: Int8.Type) throws -> Int8? {
        
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int8 = Int8(number)
        guard int8 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int8
    }
    
    func unbox(_ value: BencodeValue, as type: Int16.Type) throws -> Int16? {
        
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int16 = Int16(number)
        guard int16 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int16
    }
    
    func unbox(_ value: BencodeValue, as type: Int32.Type) throws -> Int32? {
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int32 = Int32(number)
        guard int32 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int32
    }
    
    func unbox(_ value: BencodeValue, as type: Int64.Type) throws -> Int64? {
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int64 = Int64(number)
        guard int64 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int64
    }
    
    func unbox(_ value: BencodeValue, as type: UInt.Type) throws -> UInt? {
        
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint = UInt(number)
        guard uint == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint
    }
    
    func unbox(_ value: BencodeValue, as type: UInt8.Type) throws -> UInt8? {
        
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint8 = UInt8(number)
        guard uint8 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint8
    }
    
    fileprivate func unbox(_ value: BencodeValue, as type: UInt16.Type) throws -> UInt16? {
        
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint16 = UInt16(number)
        guard uint16 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint16
    }
    
    func unbox(_ value: BencodeValue, as type: UInt32.Type) throws -> UInt32? {
        
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint32 = UInt32(number)
        guard uint32 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint32
    }
    
    func unbox(_ value: BencodeValue, as type: UInt64.Type) throws -> UInt64? {
        guard case let .integer(number) = value else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint64 = UInt64(number)
        guard uint64 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint64
    }
    
    func unbox(_ value: BencodeValue, as type: Float.Type) throws -> Float? {
        
        guard case let .integer(number) = value else {
            
             throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return Float(number)
    }
    
    func unbox(_ value: BencodeValue, as type: Double.Type) throws -> Double? {
        
        guard case let .integer(number) = value else {
            
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        return Double(number)
    }
    
    func unbox(_ value: BencodeValue, as type: String.Type) throws -> String? {
        
        guard case let .string(string) = value else {
            
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        return string
    }

    fileprivate func unbox(_ value: BencodeValue, as type: Data.Type) throws -> Data? {
       
        if case let .data(data) = value {
            return data
        }
        
        if case let .string(text) = value {
            
            return text.data(using: .ascii)
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }
    
    func unbox<T : Decodable>(_ value: BencodeValue, as type: T.Type) throws -> T? {
        return try unbox_(value, as: type) as? T
    }
    
    func unbox_(_ value: BencodeValue, as type: Decodable.Type) throws -> Any? {
        
        if type == Data.self {
            
            return try unbox(value, as: Data.self)
        } else {
            self.storage.push(container: value)
            defer { self.storage.pop() }
            return try type.init(from: self)
        }
    }
}


extension _BDecoder: SingleValueDecodingContainer {
    public func decodeNil() -> Bool {
        
        return false
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        
         return try self.unbox(self.storage.topContainer, as: Bool.self)!
    }
    
    public func decode(_ type: String.Type) throws -> String {
        
        return try self.unbox(self.storage.topContainer, as: String.self)!
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        
        return try self.unbox(self.storage.topContainer, as: Double.self)!
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        
        return try self.unbox(self.storage.topContainer, as: Float.self)!
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        return try self.unbox(self.storage.topContainer, as: Int.self)!
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        return try self.unbox(self.storage.topContainer, as: Int8.self)!
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        return try self.unbox(self.storage.topContainer, as: Int16.self)!
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        return try self.unbox(self.storage.topContainer, as: Int32.self)!
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        return try self.unbox(self.storage.topContainer, as: Int64.self)!
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        return try self.unbox(self.storage.topContainer, as: UInt.self)!
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try self.unbox(self.storage.topContainer, as: UInt8.self)!
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try self.unbox(self.storage.topContainer, as: UInt16.self)!
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try self.unbox(self.storage.topContainer, as: UInt32.self)!
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try self.unbox(self.storage.topContainer, as: UInt64.self)!
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try self.unbox(self.storage.topContainer, as: type)!
    }
    
    
}
