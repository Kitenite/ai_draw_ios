//
//  AdvancedOptionsHelp.swift
//  AiDraw
//
//  Created by Zak Rogness on 12/25/22.
//

import SwiftUI

struct AdvancedOptionsHelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Spacer()
                        Button(action: goBack) {
                            Image(systemName: "x.circle")
                        }
                    }
                    Divider()
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Restore faces:")
                            .bold()
                        Text("This option applies a post-processing effect to improve the quality of generated faces")
                    }
                    Divider()
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Sampler:")
                            .bold()
                        Text("Different samplers can produce different outcomes. Feel free to experiment!")
                    }
                    Divider()
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("CFG Scale:")
                            .bold()
                        Text("This option controls how closely the AI will follow your prompt and input image as guidance when generating the output. Lower values tend to have better image quality, and higher values tend to more closely match the prompt and input image")
                    }
                    Divider()
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Denoising Strength:")
                            .bold()
                        Text("This option controls how much the AI will respect the input image. Lower values will cause the AI to change the input image less, and higher values will cause the AI to change the image more.")
                    }
                    Divider()
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Negative Prompt:")
                            .bold()
                        Text("This allows you to tell the AI features you do not want in the output. An example negative prompt could be: 'blurry, deformed, poorly drawn'")
                    }
                    Divider()
                }
            }
            Spacer()
            Button("Go back") {
                dismiss()
            }
        }
        .padding(.all)
    }
}

private extension AdvancedOptionsHelpView {
    func goBack() -> Void {
        dismiss()
    }
}

struct AdvancedOptionsHelpView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedOptionsHelpView()
    }
}
