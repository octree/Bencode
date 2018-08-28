//
//  BT.swift
//  Swift4Bench
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation
import Bencode

func btData() -> Data {
    
    let path = Bundle.main.path(forResource: "test", ofType: "txt")!
    let url = URL(fileURLWithPath: path)
    return try! Data(contentsOf: url)
}


func decodeTest() {
    
    do {
        let bt = try BDecoder().decode(Torrent.self, from: btData())
        print(bt)
        
    } catch {
        print(error)
    }
}


