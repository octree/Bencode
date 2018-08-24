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
    
    init(referencing container: BencodeValue?, at codingPath: [CodingKey] = []) {
        self.storage = _BDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        
        guard let just = self.storage.topContainer else {
            
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard case let .dict(topContainer) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: just)
        }
        
        let container = _BKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container);
    }
    
    
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard let just = self.storage.topContainer else {
            
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard case let .list(topContainer) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: just)
        }
        
        return _BUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        
        return self
    }
}


extension _BDecoder {
    
    func unbox(_ value: BencodeValue?, as type: Bool.Type) throws -> Bool? {
        
        guard let just = value else {
            return nil
        }
        
        if case let .integer(number) = just {
            
            return number != 0
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
    }
    
    func unbox(_ value: BencodeValue?, as type: Int.Type) throws -> Int? {
        
        guard let just = value else {
            return nil
        }
        
        if case let .integer(number) = just {
            return number
        }
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
    }
    
    func unbox(_ value: BencodeValue?, as type: Int8.Type) throws -> Int8? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let int8 = Int8(number)
        guard int8 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int8
    }
    
    func unbox(_ value: BencodeValue?, as type: Int16.Type) throws -> Int16? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let int16 = Int16(number)
        guard int16 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int16
    }
    
    func unbox(_ value: BencodeValue?, as type: Int32.Type) throws -> Int32? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let int32 = Int32(number)
        guard int32 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int32
    }
    
    func unbox(_ value: BencodeValue?, as type: Int64.Type) throws -> Int64? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let int64 = Int64(number)
        guard int64 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return int64
    }
    
    func unbox(_ value: BencodeValue?, as type: UInt.Type) throws -> UInt? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let uint = UInt(number)
        guard uint == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint
    }
    
    func unbox(_ value: BencodeValue?, as type: UInt8.Type) throws -> UInt8? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let uint8 = UInt8(number)
        guard uint8 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint8
    }
    
    fileprivate func unbox(_ value: BencodeValue?, as type: UInt16.Type) throws -> UInt16? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let uint16 = UInt16(number)
        guard uint16 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint16
    }
    
    func unbox(_ value: BencodeValue?, as type: UInt32.Type) throws -> UInt32? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let uint32 = UInt32(number)
        guard uint32 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint32
    }
    
    func unbox(_ value: BencodeValue?, as type: UInt64.Type) throws -> UInt64? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        let uint64 = UInt64(number)
        guard uint64 == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
        }
        
        return uint64
    }
    
    func unbox(_ value: BencodeValue?, as type: Float.Type) throws -> Float? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            
             throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }

        return Float(number)
    }
    
    func unbox(_ value: BencodeValue?, as type: Double.Type) throws -> Double? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .integer(number) = just else {
            
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        return Double(number)
    }
    
    func unbox(_ value: BencodeValue?, as type: String.Type) throws -> String? {
        
        guard let just = value else {
            return nil
        }
        
        guard case let .string(string) = just else {
            
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
        }
        
        return string
    }

    fileprivate func unbox(_ value: BencodeValue?, as type: Data.Type) throws -> Data? {
       
        guard let just = value else {
            return nil
        }
        
        if case let .data(data) = just {
            return data
        }
        
        if case let .string(text) = just {
            
            return text.data(using: .utf8)
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: just)
    }
    
    func unbox<T : Decodable>(_ value: BencodeValue?, as type: T.Type) throws -> T? {
        return try unbox_(value, as: type) as? T
    }
    
    func unbox_(_ value: BencodeValue?, as type: Decodable.Type) throws -> Any? {
        
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
    
    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }
    
    public func decodeNil() -> Bool {
        
        return self.storage.topContainer == nil
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        
        try expectNonNull(Bool.self)
         return try self.unbox(self.storage.topContainer, as: Bool.self)!
    }
    
    public func decode(_ type: String.Type) throws -> String {
        
        try expectNonNull(String.self)
        return try self.unbox(self.storage.topContainer, as: String.self)!
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        
        try expectNonNull(Double.self)
        return try self.unbox(self.storage.topContainer, as: Double.self)!
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        
        try expectNonNull(Float.self)
        return try self.unbox(self.storage.topContainer, as: Float.self)!
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        
        try expectNonNull(Int.self)
        return try self.unbox(self.storage.topContainer, as: Int.self)!
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        
        try expectNonNull(Int8.self)
        return try self.unbox(self.storage.topContainer, as: Int8.self)!
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        
        try expectNonNull(Int16.self)
        return try self.unbox(self.storage.topContainer, as: Int16.self)!
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        
        try expectNonNull(Int32.self)
        return try self.unbox(self.storage.topContainer, as: Int32.self)!
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        
        try expectNonNull(Int64.self)
        return try self.unbox(self.storage.topContainer, as: Int64.self)!
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        
        try expectNonNull(UInt.self)
        return try self.unbox(self.storage.topContainer, as: UInt.self)!
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        
        try expectNonNull(UInt8.self)
        return try self.unbox(self.storage.topContainer, as: UInt8.self)!
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        
        try expectNonNull(UInt16.self)
        return try self.unbox(self.storage.topContainer, as: UInt16.self)!
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        
        try expectNonNull(UInt32.self)
        return try self.unbox(self.storage.topContainer, as: UInt32.self)!
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        
        try expectNonNull(type)
        return try self.unbox(self.storage.topContainer, as: UInt64.self)!
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        try expectNonNull(type)
        return try self.unbox(self.storage.topContainer, as: type)!
    }
    
    
}
