//
//  ImageSize.m
//  TEST_ImageURL
//
//  Created by cxjwin on 13-11-8.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ImageSize.h"

NSString *const kPngRangeValue = @"bytes=16-23";
NSString *const kJpgRangeValue = @"bytes=0-209";
NSString *const kGifRangeValue = @"bytes=6-9";

CGSize pngImageSizeWithHeaderData(NSData *data)
{
    int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
    [data getBytes:&w1 range:NSMakeRange(0, 1)];
    [data getBytes:&w2 range:NSMakeRange(1, 1)];
    [data getBytes:&w3 range:NSMakeRange(2, 1)];
    [data getBytes:&w4 range:NSMakeRange(3, 1)];
    int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
    
    int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
    [data getBytes:&h1 range:NSMakeRange(4, 1)];
    [data getBytes:&h2 range:NSMakeRange(5, 1)];
    [data getBytes:&h3 range:NSMakeRange(6, 1)];
    [data getBytes:&h4 range:NSMakeRange(7, 1)];
    int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
    
    return CGSizeMake(w, h);
}

static inline CGSize jpgImageSizeWithExactData(NSData *data)
{
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(2, 1)];
    [data getBytes:&w2 range:NSMakeRange(3, 1)];
    short w = (w1 << 8) + w2;
    
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(0, 1)];
    [data getBytes:&h2 range:NSMakeRange(1, 1)];
    short h = (h1 << 8) + h2;
    
    return CGSizeMake(w, h);
}

CGSize jpgImageSizeWithHeaderData(NSData *data)
{
#ifdef DEBUG
    // @"bytes=0-209"
    assert([data length] == 210);
#endif
    short word = 0x0;
    [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
    if (word == 0xdb) {
        [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
        if (word == 0xdb) {
            // 两个DQT字段
            NSData *exactData = [data subdataWithRange:NSMakeRange(0xa3, 0x4)];
            return jpgImageSizeWithExactData(exactData);
        } else {
            // 一个DQT字段
            NSData *exactData = [data subdataWithRange:NSMakeRange(0x5e, 0x4)];
            return jpgImageSizeWithExactData(exactData);
        }
    } else {
        return CGSizeZero;
    }
}

CGSize gifImageSizeWithHeaderData(NSData *data)
{
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(1, 1)];
    [data getBytes:&w2 range:NSMakeRange(0, 1)];
    short w = (w1 << 8) + w2;
    
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(3, 1)];
    [data getBytes:&h2 range:NSMakeRange(2, 1)];
    short h = (h1 << 8) + h2;
    
    return CGSizeMake(w, h);
}
