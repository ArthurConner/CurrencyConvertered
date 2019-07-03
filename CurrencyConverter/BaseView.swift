//
//  BaseView.swift
//  CurrencyConverter
//
//  Created by Arthur Conner on 7/2/19.
//  Copyright © 2019 Chris Eidhof. All rights reserved.
//

import SwiftUI

protocol ObjResource {
    associatedtype A:Decodable
   var resource:Resource<A> { get set }
    
}

struct BaseView<A:Decodable> : View, ObjResource {
    
    @ObjectBinding var resource:Resource<A>
    
    let progress: AnyView
    let unavailable : AnyView
    let available: AnyView
    
    var body: some View {
        switch resource.status{
        case .pending:
            return progress
        case .unavailable:
            return  unavailable
        case .available:
            return available
        }
    }
}

#if DEBUG
struct BaseView_Previews : PreviewProvider {
    static var previews: some View {
        BaseView(resource:Resource<FixerData>(url: "http://data.fixer.io/api/latest?access_key=dd7e92eca8f55f5d102f6802921ffa72&format=1"),
                 progress: AnyView(Text("Progress")),
                 unavailable: AnyView(Text("unavailable")),
                 available: AnyView(Text("avail")))
    }
}
#endif
