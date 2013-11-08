//
//  ViewController.m
//  TEST_ImageURL
//
//  Created by 蔡 雪钧 on 13-10-4.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import "ImageSize.h"

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
            
        default:
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
    NSString *URLString = @"http://pic12.nipic.com/20110118/1295091_171039317000_2.png";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:kPngRangeValue forHTTPHeaderField:@"Range"];
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)downloadJpgImage
{
    NSString *URLString = @"http://ww3.sinaimg.cn/thumbnail/673c0421jw1e9a6au7h5kj218g0rsn23.jpg";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:kJpgRangeValue forHTTPHeaderField:@"Range"];
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)downloadGifImage
{
    NSString *URLString = @"http://img4.21tx.com/2009/1116/92/20392.gif";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setValue:kGifRangeValue forHTTPHeaderField:@"Range"];
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

#pragma mark - 
#pragma mark - NSURLConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"recieved data length : %d", [self.recieveData length]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    switch (type) {
        case PngImage:
        {
            CGSize size = pngImageSizeWithHeaderData(data);
            NSLog(@"png image size : %@", NSStringFromCGSize(size));
        }
            break;
            
        case JpgImage:
        {
            CGSize size = jpgImageSizeWithHeaderData(data);
            NSLog(@"jpg image size : %@", NSStringFromCGSize(size));
        }
            break;
            
        case GifImage:
        {
            CGSize size = gifImageSizeWithHeaderData(data);
            NSLog(@"gif image size : %@", NSStringFromCGSize(size));
        }
            break;
            
        default:
            break;
    }
    
    [self.recieveData appendData:data];
}

@end
