//
//  ThumbnailGenerator.swift
//  RNColorMatrix
//
//  Created by Derek Yang on 2020-02-15.
//  Copyright © 2020 Derek Yang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc(ThumbnailGenerator)
class ThumbnailGenerator: NSObject {
  
  @objc
  func foo(_ input: String, callback: RCTResponseSenderBlock) -> Void {
    let url = URL(fileURLWithPath: input)
    let exists = FileManager.default.fileExists(atPath: url.absoluteString)
    callback([exists, url.absoluteString])
  }
  
  @objc
  func generateThumbnails(_ videoUrl: String, callback: @escaping RCTResponseSenderBlock) -> Void {
    DispatchQueue.global().async { [weak self] in
      var pathes = [String]()
      let url = URL(fileURLWithPath: videoUrl)
      let asset = AVAsset(url: url)
      
      let duration = asset.duration
      print(">>> duration: \(duration)")
      print(">>> CMTimeGetSeconds(duration): \(CMTimeGetSeconds(duration))")
      
      let generator = AVAssetImageGenerator(asset: asset)
      generator.appliesPreferredTrackTransform = true
      
      // TODO: Get multiple frames
      let thumbnailTime = CMTimeMake(value: 2, timescale: 1)
      do {
        let cgImage = try generator.copyCGImage(at: thumbnailTime, actualTime: nil)
        let image = UIImage(cgImage: cgImage)
        if let path = self?.saveThumbnail(image) {
          pathes.append(path.absoluteString)
        }
        
        DispatchQueue.main.async {
          callback(pathes)
        }
      } catch {
        print(error.localizedDescription)
        DispatchQueue.main.async {
          callback([])
        }
      }
    }
  }
  
  private func saveThumbnail(_ thumbnail: UIImage) -> URL {
    let filename = "\(UUID().uuidString).jpg"
    let path = getDocumentsDirectory().appendingPathComponent(filename)
    print("--> path: \(path)")
    
    let data = thumbnail.jpegData(compressionQuality: 0.8)
    try? data?.write(to: path)
    
    return path
  }
  
  private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
}
