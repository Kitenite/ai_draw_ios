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
                Button(action: addLayer) {
                    Image(systemName: "plus")
                }
                EditButton()
            }
            Divider()
            List {
                ForEach(layers.indices, id: \.self) { index in
                    LayerModalRowView(
                        layer: $layers[index]
                    ).onTapGesture {
                        activeLayerIndex = index
                    }
                    .listRowBackground(index == activeLayerIndex ? Color.blue: nil)
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            
            Spacer()
        }.padding()
    }
    func move(from source: IndexSet, to destination: Int) {
        layers.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        layers.remove(atOffsets: offsets)
    }
    
    func addLayer() {
        layers.insert(DrawingLayer(title: "Layer \(layers.count)", isVisible: true), at: 0)
    }
}

struct LayersModalView_Previews: PreviewProvider {
    @State static var layers = [
        DrawingLayer(title: "Layer title  2", image: UIImage(named: "coffee-3"), isVisible: false),
        DrawingLayer(title: "Layer title 1", image: UIImage(named: "coffee-2"), isVisible: true),
        DrawingLayer(title: "Layer title 0", image: UIImage(named: "coffee-1"), isVisible: true),
    ]
    
    static var previews: some View {
        LayersModalView(layers: $layers)
    }
}
