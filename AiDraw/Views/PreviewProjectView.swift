//
//  PreviewProjectView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/18/22.
//

import SwiftUI

struct PreviewProjectView: View {
    let image: UIImage
    let selected: Bool
    let title: String
    
    var body: some View {
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(10)
                .overlay(
                    selected ?
                    RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 5) : RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5))
            Text(title).font(.body)
        }
    }
}

struct PreviewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewProjectView(image: UIImage(named: "coffee-1")!, selected: true, title:"Title")
    }
}
