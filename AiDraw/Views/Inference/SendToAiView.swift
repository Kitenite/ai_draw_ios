//
//  SendToAIModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct SendToAiView: View {
    // Inputs
    @State var prompt: String
    var image: UIImage?
    var body: some View {
        VStack {
            ScrollView {
                if (image != nil) {
                    Image(uiImage: image!)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .border(Color.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                        .padding()
                }
                VStack {
                    Text("Describe your image").bold()
                    TextField(
                        "Be as descriptive as you can",
                        text: $prompt
                    )
                    .textFieldStyle(.roundedBorder)
                }.padding()
                
                OptionalInferenceView()
                
            }
            Button(action: {}) {
                Text("Generate Image")
                    .bold()
                    .foregroundColor(.blue)
                    
            }
            .padding([.bottom, .top], 15)
            .padding([.trailing, .leading], 20)

            .overlay(
                RoundedRectangle(cornerRadius: 25).stroke(Color.blue, lineWidth: 2)
            )
        }
    }
}

struct SendToAIModalView_Previews: PreviewProvider {
    static var previews: some View {
        let image = UIImage(named: "coffee-1")
        SendToAiView(prompt: "This is my prompt", image: image!)
    }
}
