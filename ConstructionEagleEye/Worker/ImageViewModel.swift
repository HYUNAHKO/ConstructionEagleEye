//
//  ImageViewModel.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/14/24.
//
import CoreML
import Foundation
import SwiftUI


class ImageViewModel: ObservableObject {
    let images = ["signage", "bench", "bike", "bollard", "excavator", "truck", "person", "bridge", "wall", "crane", "building", "tunnel", "airplane", "car", "dog", "cat"]
    @Published var classificationLabel = ""
    @Published var currentIndex: Int = 0

    let model: Resnet50 = {
        do {
            let config = MLModelConfiguration()
            return try Resnet50(configuration: config)
        } catch {
            fatalError("Couldn't create Resnet50")
        }
    }()
    
    public func classifyImage(image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let resizedImage = image.resizeImageTo(size: CGSize(width: 224, height: 224)),
              let buffer = resizedImage.convertToBuffer() else {
            return
        }
        
        if let output = try? model.prediction(image: buffer) {
            let results = output.classLabelProbs.sorted { $0.1 > $1.1 }
            let labels = results.map { $0.key }
            DispatchQueue.main.async {
                completion(labels)
            }
        }
    }
}



extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func convertToBuffer() -> CVPixelBuffer? {
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
