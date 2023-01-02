//
//  LayersModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct LayersModalView: View {
    @State var layers: [DrawingLayer]
    @State var activeLayerIndex: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Layers")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    print("Adding layer")
                }) {
                    Image(systemName: "plus")
                }
            }
            Divider()
            ForEach(layers.indices, id: \.self) { index in
                LayerModalRowView(
                    title: layers[index].title,
                    image: layers[index].image ?? UIImage(color: .white)!,
                    isActive: activeLayerIndex == index,
                    isVisible: $layers[index].isVisible
                )
            }
            Spacer()
        }.padding()
    }
}

struct LayersModalView_Previews: PreviewProvider {
    static var previews: some View {
        let layers = [
            DrawingLayer(image: UIImage(named: "coffee-1"), title: "Layer title", isActive: true, isVisible: true),
            DrawingLayer(image: UIImage(named: "coffee-2"), title: "Layer title", isActive: false, isVisible: true),
            DrawingLayer(image: UIImage(named: "coffee-3"), title: "Layer title", isActive: false, isVisible: false),
        ]
        LayersModalView(layers: layers)
    }
}
