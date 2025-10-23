//
//  ContentView.swift
//  AIImageGenerator-iOS
//
//  Created by Khushank Rawat on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImageGeneratorViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Input Section
                    inputSection
                    
                    // Progress Section
                    if viewModel.state == .generating {
                        progressSection
                    }
                    
                    // Images Grid
                    if !viewModel.generatedImages.isEmpty {
                        imagesSection
                    }
                    
                    // Error Section
                    if case .error(let message) = viewModel.state {
                        errorSection(message: message)
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("AI Image Generator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            Text("AI Image Generator")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Transform text into stunning visuals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Describe your image")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Prompt Input
                TextField("A majestic dragon flying over a castle...", text: $viewModel.settings.prompt, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                // Quick Settings
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Images")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Stepper("\(viewModel.settings.numberOfImages)", value: $viewModel.settings.numberOfImages, in: 1...8)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Quality")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Stepper("\(viewModel.settings.qualitySteps)", value: $viewModel.settings.qualitySteps, in: 50...500, step: 50)
                        }
                    }
                }
                
                // Generate Button
                Button(action: {
                    Task {
                        await viewModel.generateImages()
                    }
                }) {
                    HStack {
                        if viewModel.state == .generating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        
                        Text(viewModel.state == .generating ? "Generating..." : "Generate Images")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.settings.isValid ? Color.purple : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.settings.isValid || viewModel.state == .generating)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Generating Images")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.currentStep)/\(viewModel.totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
            
            Text("Step \(viewModel.currentStep) of \(viewModel.totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Images Section
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Generated Images")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.generatedImages.count) images")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(viewModel.generatedImages.sorted(by: { $0.step < $1.step })) { image in
                    ImageCardView(image: image, onSave: {
                        viewModel.saveImage(image)
                    })
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Error Section
    
    private func errorSection(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.generateImages()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Image Card View

struct ImageCardView: View {
    let image: GeneratedImage
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: image.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            
            VStack(spacing: 4) {
                Text("Step \(image.step)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Save") {
                    onSave()
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
        }
        .padding(8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: ImageGeneratorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Generation Settings") {
                    VStack(alignment: .leading) {
                        Text("Number of Images")
                        Stepper("\(viewModel.settings.numberOfImages)", value: $viewModel.settings.numberOfImages, in: 1...8)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Quality Steps")
                        Stepper("\(viewModel.settings.qualitySteps)", value: $viewModel.settings.qualitySteps, in: 50...500, step: 50)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Stream Frequency")
                        Stepper("\(viewModel.settings.streamFrequency)", value: $viewModel.settings.streamFrequency, in: 10...100, step: 10)
                    }
                }
                
                Section("API Settings") {
                    Text("API Base URL: http://localhost:5001")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
