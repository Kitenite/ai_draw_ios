//
//  PreviewProjectView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/18/22.
//

import SwiftUI

struct SelectableProjectView: View {
    let image: UIImage
    let selected: Bool
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(5)
                .overlay(
                    selected ?
                    RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 5) : RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 0.5))
            Text(title).font(.footnote).bold().truncationMode(.tail).lineLimit(1)
            Text(subtitle).font(.caption).lineLimit(1)
        }
    }
}

struct PreviewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableProjectView(image: UIImage(named: "coffee-1")!, selected: true, title: "Long title that is very long", subtitle: "Dec 31, 2022")
    }
}
