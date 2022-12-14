//
//  TutorialView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/10/22.
//

import SwiftUI

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
                    title: "AI may be asleep",
                    description: "Disclaimer: Since this is an early build, the AI may take 5 minutes to wake up to save costs. We will send you a message when it's ready.",
                    image: "onboard-sleep",
                    showOnboarding: $showOnboarding
                )
                
                OnboardingTabView(
                    title: "Create your drawing",
                    description: "Add colors for better results. You can also import drawings from your camera roll.",
                    image: "onboard-colors",
                    showOnboarding: $showOnboarding
                )
                
                OnboardingTabView(
                    title: "Send to AI",
                    description: "Once ready, a button will appear to send your drawing to the AI. Click on it to enhance your drawing.",
                    image: "onboard-send",
                    showOnboarding: $showOnboarding
                )
                
                OnboardingTabView(
                    title: "Using AI",
                    description: "Describe your drawing to the AI, be descriptive for better results. You can choose from predefined artstyles or add your own in the prompt.",
                    image: "onboard-styles",
                    showOnboarding: $showOnboarding
                )
                
                OnboardingTabView(
                    title: "Try different results",
                    description: "If you don't like the result, hit the back button and try again. A unique image will be created each time!",
                    image: "onboard-retry",
                    showOnboarding: $showOnboarding
                )
                
                OnboardingTabView(
                    title: "Edit the results",
                    description: "Draw on top of the results to edit it. You even can feed the AI's result into itself to create even more elaborate drawings!",
                    image: "onboard-edit",
                    showDismissButton: true,
                    dismissButtonText: "Get started",
                    showOnboarding: $showOnboarding
                )
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .edgesIgnoringSafeArea(.vertical)
        }
    }
}



struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}
