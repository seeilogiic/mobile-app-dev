//
//  TextRecognitionService.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import Foundation
import Vision
import UIKit

final class TextRecognitionService {
    func recognizeText(from image: UIImage) async throws -> String {
        guard let imageData = image.pngData() else {
            throw TextRecognitionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let request = VNRecognizeTextRequest()
                    request.recognitionLevel = .accurate
                    request.usesLanguageCorrection = true
                    
                    let handler = VNImageRequestHandler(data: imageData, options: [:])
                    try handler.perform([request])
                    
                    let observations = request.results ?? []
                    
                    let recognizedText = observations
                        .compactMap { observation in
                            observation.topCandidates(1).first?.string
                        }
                        .joined(separator: "\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    continuation.resume(returning: recognizedText)
                    
                } catch {
                    continuation.resume(throwing:error)
                }
            }
        }
    }
}

enum TextRecognitionError: Error {
    case invalidImage
}
