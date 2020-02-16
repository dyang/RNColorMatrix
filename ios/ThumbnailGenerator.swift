//
//  ThumbnailGenerator.swift
//  RNColorMatrix
//
//  Created by Derek Yang on 2020-02-15.
//  Copyright © 2020 Derek Yang. All rights reserved.
//

import UIKit
import AVFoundation

@objc(ThumbnailGenerator)
class ThumbnailGenerator: NSObject {
  private let numberOfThumbnails: Double = 10
  
  @objc
  func generateThumbnails(_ videoUrl: String, callback: @escaping RCTResponseSenderBlock) -> Void {
    guard let url = URL(string: videoUrl) else {
      callback([])
      return
    }
    
    DispatchQueue.global().async { [weak self] in
      guard let self = self else {
        callback([])
        return
      }
      
      var pathes = [String]()
      let asset = AVAsset(url: url)
      
      let duration = asset.duration
      print("duration: \(duration)")
      
      let generator = AVAssetImageGenerator(asset: asset)
      generator.appliesPreferredTrackTransform = true
      
      let times = self.timeSeriences(duration, numberOfFrames: self.numberOfThumbnails)
      for time in times {
        do {
          let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
          let filenameBase = UUID().uuidString
          _ = self.saveImage(UIImage(cgImage: cgImage), name: filenameBase, flag: "-o")
//          let colorInfos = self.findColors(UIImage(cgImage: cgImage))
//          if let path = self.saveColorInfos(colorInfos) {
//            pathes.append(path.absoluteString)
//          }
          
          if let filteredImage = self.applyColorMatrixFilter(UIImage(cgImage: cgImage)),
            let path = self.saveImage(filteredImage, name: filenameBase) {
            pathes.append(path.absoluteString)
          }
        }
        catch {
          print(error.localizedDescription)
        }
      }
      
      DispatchQueue.main.async {
        callback([NSNull(), pathes])
      }
    }
  }
  
  private func timeSeriences(_ duration: CMTime, numberOfFrames: Double) -> [CMTime] {
    let seconds = floor(CMTimeGetSeconds(duration))
    let increment = seconds/numberOfFrames
    print(increment)
    
    var timeValues = [CMTime]()
    var i = 0.0
    while (i < seconds) {
      timeValues.append(CMTime(seconds: i, preferredTimescale: 1))
      i += increment
    }
    return timeValues
  }
    
  private func saveImage(_ image: UIImage, name: String = UUID().uuidString, flag: String = "") -> URL? {
    let filename = "\(name)\(flag).jpg"
    let path = getDocumentsDirectory().appendingPathComponent(filename)
    print("path: \(path)")
    
    do {
      try image.jpegData(compressionQuality: 0.6)?.write(to: path)
    }
    catch {
      print(error.localizedDescription)
      return nil
    }
    
    return path
  }
  
  private func saveColorInfos(_ colorInfos: [ColorInfo]) -> URL? {
    let filename = "\(UUID().uuidString).json"
    let path = getDocumentsDirectory().appendingPathComponent(filename)
    print("path: \(path)")
    
    do {
      let encoded = try JSONEncoder().encode(colorInfos)
      try encoded.write(to: path)
    }
    catch {
      print(error.localizedDescription)
      return nil
    }
    
    return path
  }
  
  private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  struct ColorInfo: Codable {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
  }
  
  private func findColors(_ image: UIImage) -> [ColorInfo] {
    let imageWidth = Int(image.size.width)
    let imageHeight = Int(image.size.height)
    
    guard let pixelData = image.cgImage?.dataProvider?.data else { return [] }
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
    var imageColors: [ColorInfo] = []
    
    for x in 0..<imageWidth {
      for y in 0..<imageHeight {
        let pixelInfo: Int = ((imageWidth * y) + x) * 4
        imageColors.append(ColorInfo(r: CGFloat(data[pixelInfo]),
                                     g: CGFloat(data[pixelInfo + 1]),
                                     b: CGFloat(data[pixelInfo + 2]),
                                     a: CGFloat(data[pixelInfo + 3])))
      }
    }
    return imageColors
  }
  
  private func applyColorMatrixFilter(_ image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image),
      let colorMatrix = CIFilter(name: "CIColorMatrix") else { return nil }
    
    // Hardcoded image filter for test
    // This should be derived from the target image dynamically
    colorMatrix.setDefaults()
    colorMatrix.setValue(ciImage, forKey: "inputImage")
    colorMatrix.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
    colorMatrix.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
    colorMatrix.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
    colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
    
    if let outputImage = colorMatrix.outputImage {
      return UIImage(ciImage: outputImage)
    }
    
    return nil
  }
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
}
