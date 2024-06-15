//
//  LoadingView.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/6/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Image("EagleLogo") // 배경 이미지, Assets에 추가해야 함
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Loading...")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}
