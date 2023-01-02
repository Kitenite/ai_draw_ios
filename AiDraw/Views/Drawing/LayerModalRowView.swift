//
//  LayerModalRowView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct LayerModalRowView: View {
    @Binding var layer: DrawingLayer
    @State private var isShowingAlert = false
    
    var body: some View {
        HStack {
            Image(uiImage: layer.image ?? UIImage(color: .white)!)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            Text(layer.title)
            Spacer()
            Button(action: {
                DispatchQueue.main.async {
                    layer.isVisible.toggle()
                }
            }) {
                Image(
                    systemName: layer.isVisible ? "eye.fill" : "eye.slash"
                )
                .foregroundColor(
                    layer.isVisible ? .primary : .gray
                )
            }
            .buttonStyle(.borderless)
        }
    }
}


struct LayerModalRowView_Previews: PreviewProvider {
    @State static var layer = DrawingLayer(title: "Title", image: UIImage(named:"coffee-1")!, isVisible: true)
    static var previews: some View {
        LayerModalRowView(layer: $layer)
    }
}
