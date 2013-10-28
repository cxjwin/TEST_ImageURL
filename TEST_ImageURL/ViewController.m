//
//  ViewController.m
//  TEST_ImageURL
//
//  Created by 蔡 雪钧 on 13-10-4.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>

typedef NS_ENUM(NSUInteger, ImageType) {
    PngImage = 1,
    JpgImage,
    GifImage,
};

@interface ViewController ()

@property (strong, nonatomic) NSMutableData *recieveData;

@end

@implementation ViewController
{
    ImageType type;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.recieveData = [NSMutableData data];
    
    type = PngImage;
    // type = JpgImage;
    // type = GifImage;
    
    switch (type) {
        case PngImage:
        {
            [self downloadPngImage];
        }
            break;
            
        case JpgImage:
        {
            [self downloadJpgImage];
        }
            break;
            
        case GifImage:
        {
            [self downloadGifImage];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadPngImage
{
    NSString *URLString = @"http://img2.3lian.com/img2007/13/29/20080409094710646.png";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)downloadJpgImage
{
    NSString *URLString = @"http://ww3.sinaimg.cn/thumbnail/673c0421jw1e9a6au7h5kj218g0rsn23.jpg";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)downloadGifImage
{
    NSString *URLString = @"http://img4.21tx.com/2009/1116/92/20392.gif";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

#pragma mark - 
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection %@ error, error info: %@", connection, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSLog(@"expectedContentLength : %lld, %@", response.expectedContentLength, response.MIMEType);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection Loading Finished!!!, data length : %d", [self.recieveData length]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    switch (type) {
        case PngImage:
        {
            CGSize size = [self pngImageSizeWithHeaderData:data];
            NSLog(@"image size : %@", NSStringFromCGSize(size));
        }
            break;
            
        case JpgImage:
        {
            CGSize size = [self jpgImageSizeWithHeaderData:data];
            NSLog(@"image size : %@", NSStringFromCGSize(size));
        }
            break;
            
        case GifImage:
        {
            CGSize size = [self gifImageSizeWithHeaderData:data];
            NSLog(@"image size : %@", NSStringFromCGSize(size));
        }
            break;
    }

    
    [self.recieveData appendData:data];
}

#pragma mark - 
#pragma mark - Util methods
- (CGSize)pngImageSizeWithHeaderData:(NSData *)data
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

- (CGSize)jpgImageSizeWithHeaderData:(NSData *)data
{
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

- (CGSize)gifImageSizeWithHeaderData:(NSData *)data
{
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(0, 1)];
    [data getBytes:&w2 range:NSMakeRange(1, 1)];
    short w = w1 + (w2 << 8);
    
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(2, 1)];
    [data getBytes:&h2 range:NSMakeRange(3, 1)];
    short h = h1 + (h2 << 8);
    return CGSizeMake(w, h);
}

@end
