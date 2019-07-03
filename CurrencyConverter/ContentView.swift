import SwiftUI


struct Converter: View {
    
    @State private var text: String = "100"
    @State private var selection: String = "USD"
    @State private var isForward = true
    
    let rates:[String:Double]
    
    var rate: Double? {
        guard let r = rates[selection] else { return nil}
        
        if isForward  || r == 0 {
            return r
        }
        
        return 1/r
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
                if isForward {
                    Spacer()
                    Toggle(isOn: $isForward){ Text("From")}.frame(width: 100)
                    TextField($text)
                    Text("EUR")
                    Text("=")
                    Text(output)
                    Text(selection)
                    Spacer()
                } else {
                    Spacer()
                    Toggle(isOn: $isForward){ Text("To")}.frame(width: 100)
                    TextField($text)
                    Text(selection)
                    Text("=")
                    Text(output)
                    Text("EUR")
                    Spacer()
                    
                }
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
            BaseView(resource: resource,
                     progress: AnyView( VStack {
                        ProgressIndicator()
                     }),
                     unavailable: AnyView( VStack {
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
                     }),
                     available: AnyView( VStack {
                        Text("Rates")
                        Converter(rates:r)
                     })
            ).frame(width: 480, height: 300)
            
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
