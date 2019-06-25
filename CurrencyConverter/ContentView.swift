import SwiftUI


struct Converter: View {
    
    @State private var text: String = "100"
    @State private var selection: String = "USD"
    
    let rates:[String:Double]
    
    var rate: Double? {
        rates[selection]
    }
    
    let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = ""
        return f
    }()
    
    var parsedInput: Double? {
        Double(text)
    }
    
    var output: String {
        guard let rate = self.rate else { return "currency error" }
        return parsedInput.flatMap { formatter.string(from: NSNumber(value: $0 * rate)) } ?? "parse error"
    }
    
    var body: some View {
        VStack{
            HStack {
                TextField($text).frame(width: 100)
                Text("EUR")
                Text("=")
                Text(output)
                Text(selection)
            }
            HStack {
                Spacer()
                Picker(selection: $selection, label: Text("")) {
                    ForEach(self.rates.keys.sorted().identified(by: \.self)) { key in
                        Text(key)
                    }
                }
                Spacer()
            }
        }
        
    }
}


struct ProgressIndicator: NSViewRepresentable {
    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.startAnimation(nil)
        progressIndicator.style = .spinning
        return progressIndicator
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
    }
}

struct ContentView : View {
    
    @ObjectBinding var uData:UserStore
    
    var body: some View {
        Group {
            
            if uData.status == .pending {
                VStack {
                    Text("Loading...")
                    ProgressIndicator()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if uData.status == .unavailable {
                VStack {
                    Text("Could not find rates")
                    HStack{
                        Button(action: {
                            self.uData.loadFromServer()
                        }){ Text("Refresh") }
                        Button(action: {
                            self.uData.info = rateData
                            self.uData.status = .available
                        }){ Text("Use Stale") }
                    }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Converter(rates:uData.info.rates)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        }
        
        
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Converter(rates:rateData.rates)
    }
}
#endif
