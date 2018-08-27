//
//  Torrent.swift
//  Swift4Bench
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

public struct Torrent {
    
    public enum FileType {
        
        case single
        case multi
    }
    
    /*
     *  Common: pieces, pieceLength
     *  Single File: name: String, The proposed filename of the file. ; length: Int, length of file in bytes
     * Multi-file format: name: String, The proposed name of directory to store the files.
     * files: A list of dictionaries,
     * File:
     *      length: Int, The length of the file, in bytes.
     *      path: A list of strings representing the relative path to the file,
     *            For example, l6:source3:bin8:test.exee corresponds to the path
     *            "<directory name>\source\bin\test.exe".
     */
    public struct Info {
        
       public struct File: Codable {
            
            public var length: Int
            public var path: [String]
        }
        
        public var length: Int?
        public var name: String
        public var pieces: Data
        public var pieceLength: Int
        public var files: [File]?
    }
    
    public var announce: String?
    public var announceList: [[String]]?
    public var info: Info
}

extension Torrent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case announce
        case announceList = "announce-list"
        case info
    }
    
}

extension Torrent.Info: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case files
        case length
        case name
        case pieceLength = "piece length"
        case pieces
    }
}

public extension Torrent.Info {
    
    public var type: Torrent.FileType {
        
        return length == nil ? .multi : .single
    }
    
    public var filelist: [Torrent.Info.File] {
        
        switch type {
        case .single:
            return [Torrent.Info.File(length: length!, path: [name])]
        case .multi:
            return files!
        }
    }
}
