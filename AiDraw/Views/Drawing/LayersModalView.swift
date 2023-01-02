//
//  LayersModalView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct LayersModalView: View {
    @Binding var layers: [DrawingLayer]
    @State var activeLayerIndex: Int = 0
    @State private var draggedLayer: DrawingLayer?
    
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
                    layer: $layers[index],
                    isVisible: layers[index].isVisible
                ).onTapGesture {
                    activeLayerIndex = index
                    print(activeLayerIndex)
                }
                .onDrag {
                    draggedLayer = layers[index]
                    return NSItemProvider()
                }
                .onDrop(of: [.text],
                        delegate: DropViewDelegate(destinationItem: layers[index], layers: $layers, draggedItem: $draggedLayer)
                )
                .background(index == activeLayerIndex ? Color.blue: nil)
            }
            Spacer()
        }.padding()
    }
    
    
}

struct LayersModalView_Previews: PreviewProvider {
    @State static var layers = [
        DrawingLayer(title: "Layer title", image: UIImage(named: "coffee-1"), isActive: true, isVisible: true),
        DrawingLayer(title: "Layer title", image: UIImage(named: "coffee-2"), isActive: false, isVisible: true),
        DrawingLayer(title: "Layer title", image: UIImage(named: "coffee-3"), isActive: false, isVisible: false),
    ]
    
    static var previews: some View {
        LayersModalView(layers: $layers)
    }
}
