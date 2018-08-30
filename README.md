# Bencode

bencode parser, Powered by [ParserCombinator](https://github.com/octree/ParserCombinator)





## Usage



```swift
struct Fuck: Codable {
    
    var name: String
    var age: Int?
    var you: You
    var ints: [Int]
}

struct You: Decodable {

    var name: String
}

do {
    let decoder = BDecoder()
    let txt = "d4:name6:Octree4:intsli123ei234ee3:youd4:name3:Biuee";
    let rt = try decoder.decode(Fuck.self, from: txt.data(using: .utf8)!)
    print(rt)

    // let data = try Bencoder().encode(rt)
} catch {
    print(error)
}
```





## Installation



### Carthage



```shell
carthage "github/bencode" ~> 0.1.0
```




