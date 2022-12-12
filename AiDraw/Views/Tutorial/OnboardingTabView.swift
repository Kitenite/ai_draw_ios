//
//  OnboardingTabView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/11/22.
//

import SwiftUI

struct OnboardingTabView: View {
    var title: String
    var description: String
    var image: String
    var showDismissButton = false
    var dismissButtonText = "Get Started"
    @Binding var showOnboarding: Bool
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: image)!)
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(description)
                .font(.title2)
                .padding(.horizontal)
            
            Spacer()
            
            if (showDismissButton) {
                Button(action: {
                    showOnboarding.toggle()
                }) {
                    Text(dismissButtonText)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(lineWidth: 2)
                        )
                }.padding(.top)
            }
            Spacer()
        }
    }
}

struct OnboardingTabView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTabView(
            title: "Title",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            image: "coffee-1",
            showDismissButton: true,
            dismissButtonText: "Button title",
            showOnboarding: .constant(true)
        )
    }
}
