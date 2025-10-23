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
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 32) {
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("AI Generator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
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
        VStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.8),
                                Color.blue.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("AI Generator")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Transform text into stunning human faces")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(spacing: 24) {
            // Prompt Input Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.purple)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Describe the person you want to generate")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 12) {
                    TextField("A beautiful woman with long hair smiling...", text: $viewModel.settings.prompt, axis: .vertical)
                        .textFieldStyle(ModernTextFieldStyle())
                        .lineLimit(3...6)
                    
                    // Quick Settings Row
                    HStack(spacing: 16) {
                        SettingCard(
                            icon: "photo.stack",
                            title: "Images",
                            value: "\(viewModel.settings.numberOfImages)",
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.settings.numberOfImages = min(8, max(1, viewModel.settings.numberOfImages + 1))
                                }
                            }
                        )
                        
                        SettingCard(
                            icon: "gauge.high",
                            title: "Quality",
                            value: "\(viewModel.settings.qualitySteps)",
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.settings.qualitySteps = min(500, max(50, viewModel.settings.qualitySteps + 50))
                                }
                            }
                        )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            
            // Generate Button
            Button(action: {
                Task {
                    await viewModel.generateImages()
                }
            }) {
                HStack(spacing: 12) {
                    if viewModel.state == .generating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text(viewModel.state == .generating ? "Generating..." : "Generate Images")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: viewModel.settings.isValid ? 
                            [Color.purple, Color.blue] : 
                            [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(viewModel.settings.isValid ? 1.0 : 0.98)
                .animation(.spring(response: 0.3), value: viewModel.settings.isValid)
            }
            .disabled(!viewModel.settings.isValid || viewModel.state == .generating)
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.purple)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Generating Images")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.currentStep)/\(viewModel.totalSteps)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
            
            VStack(spacing: 12) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(ModernProgressViewStyle())
                
                HStack {
                    Text("Step \(viewModel.currentStep) of \(viewModel.totalSteps)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.purple)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Images Section
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "photo.stack")
                    .foregroundColor(.purple)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Generated Images")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.generatedImages.count) images")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(viewModel.generatedImages.sorted(by: { $0.step < $1.step })) { image in
                    ModernImageCard(image: image, onSave: {
                        viewModel.saveImage(image)
                    })
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Error Section
    
    private func errorSection(message: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Oops! Something went wrong")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Button("Try Again") {
                Task {
                    await viewModel.generateImages()
                }
            }
            .buttonStyle(ModernButtonStyle())
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Custom Components

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.system(size: 16, weight: .medium))
    }
}

struct ModernProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 8)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 100, height: 8)
                .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)
        }
    }
}

struct SettingCard: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purple)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernImageCard: View {
    let image: GeneratedImage
    let onSave: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 160)
                
                Image(uiImage: image.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Overlay with step info
                VStack {
                    HStack {
                        Spacer()
                        Text("Step \(image.step)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            Button(action: onSave) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isHovered.toggle()
            }
        }
    }
}

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: ImageGeneratorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Generation Settings Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Generation Settings")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(spacing: 16) {
                                SettingRow(
                                    icon: "photo.stack",
                                    title: "Number of Images",
                                    value: "\(viewModel.settings.numberOfImages)",
                                    range: 1...8
                                ) { newValue in
                                    viewModel.settings.numberOfImages = newValue
                                }
                                
                                SettingRow(
                                    icon: "gauge.high",
                                    title: "Quality Steps",
                                    value: "\(viewModel.settings.qualitySteps)",
                                    range: 50...500,
                                    step: 50
                                ) { newValue in
                                    viewModel.settings.qualitySteps = newValue
                                }
                                
                                SettingRow(
                                    icon: "waveform",
                                    title: "Stream Frequency",
                                    value: "\(viewModel.settings.streamFrequency)",
                                    range: 10...100,
                                    step: 10
                                ) { newValue in
                                    viewModel.settings.streamFrequency = newValue
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        
                        // API Settings Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "network")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("API Settings")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Server URL")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("http://localhost:5001")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.purple)
                }
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    let range: ClosedRange<Int>
    let step: Int
    let action: (Int) -> Void
    
    init(icon: String, title: String, value: String, range: ClosedRange<Int>, step: Int = 1, action: @escaping (Int) -> Void) {
        self.icon = icon
        self.title = title
        self.value = value
        self.range = range
        self.step = step
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.purple)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    let newValue = max(range.lowerBound, Int(value) ?? range.lowerBound - step)
                    action(newValue)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                }
                .disabled(Int(value) ?? range.lowerBound <= range.lowerBound)
                
                Button(action: {
                    let newValue = min(range.upperBound, Int(value) ?? range.lowerBound + step)
                    action(newValue)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                }
                .disabled(Int(value) ?? range.lowerBound >= range.upperBound)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
