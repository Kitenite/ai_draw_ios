//
//  OptionPickerView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/2/23.
//

import SwiftUI

struct Option {
    var title: String
    var image: UIImage
}
struct OptionPickerView: View {
    
    var options: [Option] = [
        Option(title: "Option 1", image: UIImage(named: "coffee-1")!),
        Option(title: "Option 2", image: UIImage(named: "coffee-2")!),
        Option(title: "Option 3", image: UIImage(named: "coffee-3")!),
        Option(title: "Option 4", image: UIImage(named: "coffee-4")!),
        Option(title: "Option 1", image: UIImage(named: "coffee-1")!),
        Option(title: "Option 2", image: UIImage(named: "coffee-2")!),
        Option(title: "Option 3", image: UIImage(named: "coffee-3")!),
        Option(title: "Option 4", image: UIImage(named: "coffee-4")!)
        
    ]
    
    @State private var selectedOptionIndex: Int = 0
    
    let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(options.indices, id: \.self) { index in
                    SelectableOptionView(
                        image: options[index].image,
                        selected: selectedOptionIndex == index,
                        title: options[index].title
                    )
                    .onTapGesture {
                        selectedOptionIndex = index
                    }
                }
            }
            .padding(.all, 20)
        }
    }
}

struct OptionPickerView_Previews: PreviewProvider {
    static var previews: some View {
        OptionPickerView()
    }
}
