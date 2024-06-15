//
//  NoticeBoardView.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/14/24.
//

import SwiftUI

struct NoticeBoardView: View {
    @State private var notices: [String] = [
        "Notice 1: Please wear your helmets at all times.",
        "Notice 2: Remember to take breaks and stay hydrated.",
        "Notice 3: Report any unsafe conditions immediately."
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Notice Board")
                .font(.largeTitle)
                .padding()

            List(notices, id: \.self) { notice in
                Text(notice)
            }
        }
        .navigationTitle("Notice Board")
    }
}

struct NoticeBoardView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeBoardView()
    }
}
