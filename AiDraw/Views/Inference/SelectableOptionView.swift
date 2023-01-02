//
//  SelectableOptionView.swift
//  AiDraw
//
//  Created by Kiet Ho on 1/2/23.
//

import SwiftUI

struct SelectableOptionView: View {
    let image: UIImage
    let selected: Bool
    let title: String
    
    var body: some View {
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 100, height: 100)
                .cornerRadius(5)
                .overlay(
                    selected ?
                    RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 5) : RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 0.5))
            Text(title).font(.footnote).bold().truncationMode(.tail).lineLimit(1)
        }
    }
}

struct SelectableOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableOptionView(image: UIImage(named: "coffee-1")!, selected: true, title: "Option title")
    }
}
