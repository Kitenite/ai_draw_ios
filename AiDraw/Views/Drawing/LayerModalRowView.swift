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
            }
            Button(action: {
                isShowingAlert = true
            }) {
                Image(systemName: "trash")
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Delete layer?"),
                    message: Text("This is not reversable"),
                    primaryButton: .default(
                        Text("Cancel"),
                        action: {}
                    ),
                    secondaryButton: .destructive(
                        Text("Delete"),
                        action: {}
                    )
                    
                )
            }.foregroundColor(.primary)
        }
        .padding()
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
