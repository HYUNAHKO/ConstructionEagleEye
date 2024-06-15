//
//  OpenWeatherResponse.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/15/24.
//
import Foundation

struct OpenWeatherResponse: Decodable {
    let name: String
    let main: OpenWeatherMain
    let weather: [OpenWeatherWeather]

    init(name: String, main: OpenWeatherMain, weather: [OpenWeatherWeather]) {
        self.name = name
        self.main = main
        self.weather = weather
    }
}

struct OpenWeatherMain: Decodable {
    let temp: Double
    let humidity: Double  // 습도 추가

    init(temp: Double, humidity: Double) {
        self.temp = temp
        self.humidity = humidity // 습도 추가
    }
}

struct OpenWeatherWeather: Decodable {
    let description: String
    let main: String

    init(description: String, main: String) {
        self.description = description
        self.main = main
    }
}

public struct Weather {
    let location: String
    let temperature: String
    let humidity: Double
    let description: String
    let main: String
    let discomfortIndex: String

    init(response: OpenWeatherResponse) {
        location = response.name
        temperature = "\(Int(response.main.temp))°C"
        humidity = response.main.humidity
        description = response.weather.first?.description ?? "No description available"
        main = response.weather.first?.main ?? "Unknown"

        // Calculate Discomfort Index
        let temp = response.main.temp
        let humidity = response.main.humidity
        discomfortIndex = Weather.calculateDiscomfortIndex(temp: temp, humidity: humidity)
    }

    static func calculateDiscomfortIndex(temp: Double, humidity: Double) -> String {
        let discomfortIndex = 0.81 * temp + 0.01 * humidity * (0.99 * temp - 14.3) + 46.3
        return String(format: "%.1f", discomfortIndex)
    }
}
