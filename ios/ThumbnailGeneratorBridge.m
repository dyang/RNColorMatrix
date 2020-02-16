//
//  ThumbnailGeneratorBridge.m
//  RNColorMatrix
//
//  Created by Derek Yang on 2020-02-15.
//  Copyright © 2020 Derek Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ThumbnailGenerator, NSObject)

RCT_EXTERN_METHOD(generateThumbnails:(NSString *)videoUrl callback:(RCTResponseSenderBlock)callback)

@end
