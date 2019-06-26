import SwiftUI
import Combine

class  UserStore : BindableObject {
    
    enum loadStatus {
        case pending
        case unavailable
        case available
    }
    
    let didChange = PassthroughSubject<UserStore, Never>()
    
    var info =  FixerData.pendingRate(){
        didSet {
            didChange.send(self)
        }
    }
    
    var status:loadStatus = .pending {
        didSet {
            didChange.send(self)
        }
    }
    
    func loadFromServer(){
        
        guard let url = URL(string:  "http://data.fixer.io/api/latest?access_key=dd7e92eca8f55f5d102f6802921ffa72&format=1")else {
            print("Bad url")
            return
        }
        
        let _ = URLSession.shared.dataTaskPublisher(for: url)
            .map({ (inputTuple) -> Data in
                return inputTuple.data
            })
            .decode(type: FixerData.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {x in
                switch x{
                case .failure:
                    self.status = .unavailable
                case .finished:
                    self.status = .available
                }
            } , receiveValue:{ receivedValue in
                    self.info = receivedValue
            })
        
    }
    
}


