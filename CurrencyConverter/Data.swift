import SwiftUI
import Combine

struct RateInfo :Codable{
    let success:Bool
    let timestamp:Int
    let base:String
    let date:String
    let rates:[String:Double]
    
    static func pendingRate() -> RateInfo{
        RateInfo(success: false, timestamp: -1, base: "", date: "empty", rates: [:])
    }
    
}


let rateData:RateInfo = load("rates.json")

func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
