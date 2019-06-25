import SwiftUI
import Combine

class  UserStore : BindableObject {
    
    enum loadStatus {
        case pending
        case unavailable
        case available
    }
    
    let didChange = PassthroughSubject<UserStore, Never>()
    
    var info =  RateInfo.pendingRate(){// rateData{ //
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
            // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
            .map({ (inputTuple) -> Data in
                return inputTuple.data
            })
            .decode(type: RateInfo.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            //.assign(to:\.info,on:self)
            .sink(receiveCompletion: {x in
                
                switch x{
                case .failure:
                    self.status = .unavailable
                case .finished:
                    self.status = .available
                }
                
            }
                , receiveValue:{ receivedValue in
                    self.info = receivedValue
            })
        
    }
    
}


