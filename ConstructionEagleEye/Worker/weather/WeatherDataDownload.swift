//
//  WeatherDataDownload.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/15/24.
//
import Foundation
import CoreLocation

enum WeatherServiceError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case decodingError
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .requestFailed:
            return "The request failed."
        case .invalidResponse:
            return "The response is invalid."
        case .decodingError:
            return "Failed to decode the response."
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)."
        }
    }
}

class WeatherDataDownload {

    private let API_KEY = "7a248c03394f2502acc106d948dc0b3b"

    func getWeather(location: CLLocationCoordinate2D) async throws -> OpenWeatherResponse {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lon", value: "\(location.longitude)"),
            URLQueryItem(name: "appid", value: API_KEY),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components.url else {
            print("Invalid URL")
            throw WeatherServiceError.invalidURL
        }

        print("URL: \(url.absoluteString)")

        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            throw WeatherServiceError.invalidResponse
        }

        print("Response status code: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            print("Failed response with status code: \(httpResponse.statusCode)")
            throw WeatherServiceError.invalidResponse
        }

        do {
            let decodedData = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            print("Weather data fetched successfully")
            return decodedData
        } catch {
            print("Decoding error: \(error)")
            throw WeatherServiceError.decodingError
        }
    }
}

