import SwiftUI
import Combine


final class Resource<A:Decodable>: BindableObject {
    let didChange = PassthroughSubject<A?, Never>()
    let url: String
    
    enum loadStatus {
        case pending
        case unavailable
        case available
    }
    
    var status:loadStatus = .pending {
        didSet {
            didChange.send(self.value)
        }
    }
    
    var value: A? {
        didSet {
            DispatchQueue.main.async {
                self.didChange.send(self.value)
            }
        }
    }
    
    init(url: String) {
        self.url = url
        reload()
    }

    //var pub:URLSession.DataTaskPublisher?
    
    func reload() {
        guard let url = URL(string: url )else {
            print("Bad url \(self.url)")
            self.status = .unavailable
            return
        }
        
      let _ = URLSession.shared.dataTaskPublisher(for: url)
            .map({ (inputTuple) -> Data in
                return inputTuple.data
            })
            .decode(type: A.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {x in
                switch x{
                case .failure:
                    self.status = .unavailable
                case .finished:
                    self.status = .available
                }
            } , receiveValue:{ receivedValue in
                self.value = receivedValue
            }).eraseToAnySubscriber()
        
        
    }
}


