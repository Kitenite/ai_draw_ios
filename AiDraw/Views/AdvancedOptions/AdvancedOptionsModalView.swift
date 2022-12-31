//
//  AdvancedOptionsModalView.swift
//  AiDraw
//
//  Created by Zak Rogness on 12/23/22.
//

import SwiftUI

struct AdvancedOptionsModalView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var isHelpPresented = false
    @State private var showSetDefaultSuccessIcon = false
    internal var analytics = AnalyticsHelper.shared

    // Inputs
    @Binding var advancedOptions: AdvancedOptions
    
    // Unmodified options for use on cancel
    @State private var unmodifiedAdvancedOptions = AdvancedOptions()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    HStack() {
                        Button(action: goBackWithoutSaving) {
                            Text("Cancel")
                        }
                        Spacer()
                        Button(action: showHelp) {
                            Image(systemName: "questionmark.circle")
                        }
                        .sheet(isPresented: $isHelpPresented) {
                            AdvancedOptionsHelpView()
                        }
                    }
                    Divider()
                }
                HStack {
                    Toggle(isOn: $advancedOptions.restore_faces) {
                        Text("Restore faces:")
                    }.frame(maxWidth: 250)
                    Divider()
                    Group {
                        Text("Sampler:")
                        Picker("Select a sampler", selection: $advancedOptions.sampler_index) {
                            ForEach(Sampler.allCases.map { $0.rawValue }, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.menu )
                    }
                }
                //TODO numberformatter doesn't work very well, make custom formatter
                HStack {
                    Text("Seed:")
                    TextField("Seed", value: $advancedOptions.seed, formatter: NumberFormatter())
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
                Group {
                    Divider()
                    VStack {
                        Text("CFG Scale: \(String(format: "%.1f", advancedOptions.cfg_scale))")
                        Slider(
                            value: $advancedOptions.cfg_scale,
                            in: 1...30,
                            step: 0.5
                        )
                    }
                    Divider()
                    VStack {
                        Text("Denoising Strength: \(String(format: "%.2f", advancedOptions.denoising_strength))")
                        Slider(
                            value: $advancedOptions.denoising_strength,
                            in: 0...1,
                            step: 0.01
                        )
                    }
                    Divider()
                }
                VStack {
                    Text("Negative Prompt:")
                    TextField("Negative prompt", text: $advancedOptions.negative_prompt)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                }
            }.padding()
            VStack {
                Button(action: {
                    Task {
                        await setDefaultAdvancedOptions()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(
                            "Set selected options as default"
                        )
                        if (showSetDefaultSuccessIcon) {
                            Image(systemName: "checkmark")
                        }
                        Spacer()
                    }
                }.fontWeight(Font.Weight.light)
                Divider()
                Button("Save options") {
                    dismiss()
                }.fontWeight(Font.Weight.bold)
            }
        }.onAppear {
            saveUnmodifiedAdvancedOptions()
        }
    }
}

private extension AdvancedOptionsModalView {
    func showHelp() -> Void {
        isHelpPresented = true
    }
    
    func saveUnmodifiedAdvancedOptions() -> Void {
        unmodifiedAdvancedOptions = advancedOptions
        analytics.logEvent(id: "save-advanced-options", title: "Save advanced options")

    }
    
    func setDefaultAdvancedOptions() async -> Void {
        let encodedAdvancedOptionsData = try? JSONEncoder().encode(advancedOptions)
        if (encodedAdvancedOptionsData != nil) {
            UserDefaults.standard.set(encodedAdvancedOptionsData, forKey: Constants.DEFAULT_ADVANCED_OPTIONS_KEY)
            showSetDefaultSuccessIcon = true
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showSetDefaultSuccessIcon = false
        }
    }
    
    func goBackWithoutSaving() -> Void {
        advancedOptions = unmodifiedAdvancedOptions
        dismiss()
    }
}

struct AdvancedOptionsModalView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedOptionsModalView(advancedOptions: .constant(AdvancedOptions()))
    }
}
