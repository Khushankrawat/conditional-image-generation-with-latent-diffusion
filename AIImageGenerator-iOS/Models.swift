//
//  Models.swift
//  AIImageGenerator-iOS
//
//  Created by Khushank Rawat on 23/10/25.
//

import Foundation
import UIKit

// MARK: - API Models

struct GenerateRequest: Codable {
    let prompt: String
    let n_images: Int
    let n_inf_steps: Int
    let stream_freq: Int
    
    init(prompt: String, nImages: Int = 4, nInfSteps: Int = 500, streamFreq: Int = 50) {
        self.prompt = prompt
        self.n_images = nImages
        self.n_inf_steps = nInfSteps
        self.stream_freq = streamFreq
    }
}

struct GenerateResponse: Codable {
    let job_id: String
}

struct JobStatus: Codable {
    let finished: Bool
    let response: [ImageResponse]?
}

struct ImageResponse: Codable {
    let t: Int
    let total_t: Int
    let img: String
    let latent: String?
}

// MARK: - UI Models

enum GenerationState: Equatable {
    case idle
    case generating
    case completed
    case error(String)
}

struct GeneratedImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let step: Int
    let totalSteps: Int
    let timestamp: Date
}

// MARK: - Settings Model

struct GenerationSettings {
    var prompt: String = ""
    var numberOfImages: Int = 4
    var qualitySteps: Int = 500
    var streamFrequency: Int = 50
    
    var isValid: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
