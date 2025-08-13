


// API.swift
import Foundation

struct API {
    static let apiKey: String = {
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("Error: API_KEY is not set in Info.plist.")
        }
        return apiKey
    }()
}
