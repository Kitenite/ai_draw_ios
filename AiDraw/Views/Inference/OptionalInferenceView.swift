//
//  OptionalInferenceView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/2/23.
//

import SwiftUI

struct OptionalInferenceView: View {
    var body: some View {
        VStack {
            Text("Optional").bold()
            
            DisclosureGroup("Choose medium") {
                OptionPickerView()
            }
            
            DisclosureGroup("Choose style") {
                Text("Long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here.")
            }
            
            DisclosureGroup("Choose artist") {
                Text("Long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here.")
            }
            
            DisclosureGroup("Advanced options") {
                Text("Long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here long terms and conditions here.")
            }
        }.padding()
        
    }
}

struct OptionalInferenceView_Previews: PreviewProvider {
    static var previews: some View {
        OptionalInferenceView()
    }
}
