# Bencode

bencode parser, Powered by [ParserCombinator](https://github.com/octree/ParserCombinator)





## Usage



```swift
struct Fuck: Decodable {
    
    var name: String
    var age: Int
    var you: You
}

struct You: Decodable {

    var name: String
}

do {
        let decoder = BDecoder()
        let txt = "d4:name6:Octree3:agei22e3:youd4:name3:Biuee";
        let rt = try decoder.decode(Fuck.self, from: txt)
        print(rt)
    } catch {
        print(error)
    }
```





## Installation



### Carthage



```shell
carthage "github/bencode" ~> 0.1.0
```





## Todo



- [ ] support optional

