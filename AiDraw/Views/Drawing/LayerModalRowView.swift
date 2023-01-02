//
//  LayerModalRowView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct LayerModalRowView: View {
    @Binding var layer: DrawingLayer
    @State var isVisible: Bool
    @State private var isShowingAlert = false
    
    var body: some View {
        HStack {
            Image(uiImage: layer.image!)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            Text(layer.title)
            Spacer()
            Button(action: toggleIsVisible) {
                Image(
                    systemName: isVisible ? "eye.fill" : "eye.slash"
                )
                .foregroundColor(
                    isVisible ? .primary : .gray
                )
            }.buttonStyle(.borderless)
        }
    }
    
    func toggleIsVisible() {
        isVisible.toggle()
        layer.isVisible = isVisible
    }
}


struct LayerModalRowView_Previews: PreviewProvider {
    @State static var layer = DrawingLayer(title: "Title", image: UIImage(named:"coffee-1")!, isActive: true, isVisible: true)
    static var previews: some View {
        LayerModalRowView(layer: $layer, isVisible: layer.isVisible)
    }
}
