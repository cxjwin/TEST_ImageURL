//
//  ImageSize.h
//  TEST_ImageURL
//
//  Created by cxjwin on 13-11-8.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

extern NSString *const kPngRangeValue;
extern NSString *const kJpgRangeValue;
extern NSString *const kGifRangeValue;

CGSize pngImageSizeWithHeaderData(NSData *data);

CGSize jpgImageSizeWithHeaderData(NSData *data);

CGSize gifImageSizeWithHeaderData(NSData *data);

