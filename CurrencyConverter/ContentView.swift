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
    
    @ObjectBinding var resource = Resource<FixerData>(url: "http://data.fixer.io/api/latest?access_key=dd7e92eca8f55f5d102f6802921ffa72&format=1")
    
    var body: some View {
        
        let r = self.resource.value?.rates ?? [:]
        
        return Group {
           
 
            if resource.status == .pending {
                VStack {
                    Text("Loading...")
                    ProgressIndicator()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if resource.status == .unavailable {
                VStack {
                    Text("Could not find rates")
                    HStack{
                        Button(action: {
                            self.resource.reload()
                        }){ Text("Refresh") }
                        Button(action: {
                            self.resource.value = rateData
                            self.resource.status = .available
                        }){ Text("Use Stale") }
                    }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {

                Converter(rates:r)
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
