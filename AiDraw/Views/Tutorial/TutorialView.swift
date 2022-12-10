//
//  TutorialView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/10/22.
//

import SwiftUI

struct TutorialView: View {
//    @AppStorage("showOnboarding") var showOnboarding = true
    @State var showOnboarding = true
    var body: some View {
        HStack{
            Text("HOME")
        }.fullScreenCover(isPresented: $showOnboarding, content: {
            OnboardingView(showOnboarding: $showOnboarding)
        })
    }
}

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showOnboarding.toggle()
                }) {
                    Text("Skip")
                }.padding()
            }
            TabView {
                OnboardingTabView(
                    title: "Title 1",
                    description: "Description",
                    image: "bell",
                    showOnboarding: $showOnboarding
                )
                OnboardingTabView(
                    title: "Title 2",
                    description: "Description",
                    image: "airplane",
                    showDismissButton: true,
                    showOnboarding: $showOnboarding
                )
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct OnboardingTabView: View {
    var title: String
    var description: String
    var image: String
    var showDismissButton = false
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()
            Text(description)
                .font(.title)
                .padding()
            
            Text(title)
                .font(.title2)
            
            if (showDismissButton) {
                Button(action: {
                    showOnboarding.toggle()
                }) {
                    Text("Get started")
                        .font(.title)
                }
            }
        }
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
