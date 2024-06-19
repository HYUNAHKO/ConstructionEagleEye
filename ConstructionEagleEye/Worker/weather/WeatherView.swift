//
//  WeatherView.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/15/24.
//
import SwiftUI

struct WeatherView: View {

    var openWeatherResponse: OpenWeatherResponse

    private let iconList = [
        "Clear": "☀️",
        "Clouds": "☁️",
        "Mist": "☁️",
        "": "?",
        "Drizzle": "🌧",
        "Thunderstorm": "⛈",
        "Rain": "🌧",
        "Snow": "🌨"
    ]

    private var emoji: String {
        let discomfortIndex = Weather(response: openWeatherResponse).discomfortIndex
        let index = Double(discomfortIndex) ?? 0

        if index >= 80 {
            return "😠" // 찡그리는 표정
        } else if index >= 68 {
            return "😓" // 땀흘리는 표정
        } else {
            return "😊" // 웃는 표정
        }
    }

    var body: some View {
            let weather = Weather(response: openWeatherResponse)

            VStack {
                Text(weather.location)
                    .font(.title2)
                    .padding()
                HStack{
                    Text(weather.temperature)
                        .font(.system(size: 30))
                        .bold()
                    
                    Text(iconList[weather.main] ?? "?")
                        .font(.title)
                        .padding()
                }
                HStack {
                    Text("Discomfort Index : \(weather.discomfortIndex)")
                        .font(.title3)
                    Text(emoji)
                        .font(.title2)
                }
                .padding()
            }
    }
}
