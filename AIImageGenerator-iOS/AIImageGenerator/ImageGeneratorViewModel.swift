//
//  ImageGeneratorViewModel.swift
//  AIImageGenerator-iOS
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor
class ImageGeneratorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state: GenerationState = .idle
    @Published var generatedImages: [GeneratedImage] = []
    @Published var progress: Double = 0.0
    @Published var currentStep: Int = 0
    @Published var totalSteps: Int = 0
    @Published var settings = GenerationSettings()
    
    // MARK: - Private Properties
    private let apiBaseURL = "http://localhost:5001"
    private var currentJobId: String?
    private var pollingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - API Methods
    
    func generateImages() async {
        guard settings.isValid else {
            state = .error("Please enter a prompt")
            return
        }
        
        state = .generating
        generatedImages.removeAll()
        progress = 0.0
        currentStep = 0
        totalSteps = settings.qualitySteps
        
        do {
            let jobId = try await startGeneration()
            currentJobId = jobId
            startPolling()
        } catch {
            state = .error("Failed to start generation: \(error.localizedDescription)")
        }
    }
    
    private func startGeneration() async throws -> String {
        let request = GenerateRequest(
            prompt: settings.prompt,
            nImages: settings.numberOfImages,
            nInfSteps: settings.qualitySteps,
            streamFreq: settings.streamFrequency
        )
        
        guard let url = URL(string: "\(apiBaseURL)/text_to_image") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        let generateResponse = try JSONDecoder().decode(GenerateResponse.self, from: data)
        return generateResponse.job_id
    }
    
    private func startPolling() {
        guard let jobId = currentJobId else { return }
        
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task {
                await self?.pollJobStatus(jobId: jobId)
            }
        }
    }
    
    private func pollJobStatus(jobId: String) async {
        do {
            guard let url = URL(string: "\(apiBaseURL)/jobs/\(jobId)/") else {
                throw APIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let jobStatus = try JSONDecoder().decode(JobStatus.self, from: data)
            
            if let responses = jobStatus.response {
                await processImageResponses(responses)
            }
            
            if jobStatus.finished {
                stopPolling()
                state = .completed
            }
            
        } catch {
            stopPolling()
            state = .error("Failed to get job status: \(error.localizedDescription)")
        }
    }
    
    private func processImageResponses(_ responses: [ImageResponse]) async {
        for response in responses {
            if let image = decodeBase64Image(response.img) {
                let generatedImage = GeneratedImage(
                    image: image,
                    step: response.t,
                    totalSteps: response.total_t,
                    timestamp: Date()
                )
                
                // Update progress
                currentStep = response.t
                totalSteps = response.total_t
                progress = Double(response.t) / Double(response.total_t)
                
                // Add or update image
                if let existingIndex = generatedImages.firstIndex(where: { $0.step == response.t }) {
                    generatedImages[existingIndex] = generatedImage
                } else {
                    generatedImages.append(generatedImage)
                }
            }
        }
    }
    
    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    // MARK: - Helper Methods
    
    private func decodeBase64Image(_ base64String: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }
    
    func saveImage(_ image: GeneratedImage) {
        UIImageWriteToSavedPhotosAlbum(image.image, nil, nil, nil)
    }
    
    func reset() {
        state = .idle
        generatedImages.removeAll()
        progress = 0.0
        currentStep = 0
        totalSteps = 0
        stopPolling()
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Request failed"
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}
