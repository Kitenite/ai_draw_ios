//
//  LayerModalRowView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/1/23.
//

import SwiftUI

struct LayerModalRowView: View {
    let title: String
    let image: UIImage
    let isActive: Bool
    @Binding var isVisible: Bool
    @State private var isShowingAlert = false
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            Text(title)
            Spacer()
            Button(action: {
                isVisible.toggle()
            }) {
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
        .background(isActive ? Color.blue: nil)
    }
}

struct LayerModalRowView_Previews: PreviewProvider {
    @State var isVisible = true
    static var previews: some View {
        LayerModalRowView(title: "Layer title", image: UIImage(named:"coffee-1")!, isActive: true, isVisible: .constant(true))
    }
}
