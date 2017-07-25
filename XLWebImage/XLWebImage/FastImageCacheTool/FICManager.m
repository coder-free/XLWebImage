//
//  FICManager.m
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/15.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import "FICManager.h"
#import "FICDPhoto.h"

@interface FICManager () <FICImageCacheDelegate>

@end

static NSArray *FICDPhotoSquareImageSizes = nil;

@implementation FICManager

+ (FICManager *)sharedManager
{
    static FICManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        CGFloat imageWidth;
        imageWidth = (NSInteger)(([sharedAccountManagerInstance screenPortraitBounds].size.width - 5 * 6 - 6) / 5);
        CGFloat screenWidth = [sharedAccountManagerInstance screenPortraitBounds].size.width;
        UIEdgeInsets sectionInset = UIEdgeInsetsZero;
        CGFloat gridSpace = 1;
        NSInteger columns = 3;
        CGFloat itemWidth = (NSInteger)(screenWidth - sectionInset.left - sectionInset.right - (gridSpace * (columns - 1))) / columns;
        
        UIEdgeInsets sectionInset2 = UIEdgeInsetsMake(10, 10, 10, 10);
        CGFloat gridSpace2 = 10;
        NSInteger columns2 = 3;
        CGFloat itemWidth2 = (NSInteger)(screenWidth - sectionInset2.left - sectionInset2.right - (gridSpace2 * (columns2 - 1))) / columns2;
        sharedAccountManagerInstance.FICDPhotoSquareImageSizes
        = @[
            [NSValue valueWithCGSize:CGSizeMake(imageWidth, imageWidth)],
            [NSValue valueWithCGSize:CGSizeMake(itemWidth, itemWidth)],
            [NSValue valueWithCGSize:CGSizeMake(itemWidth2, itemWidth2)],
            [NSValue valueWithCGSize:CGSizeMake(30, 30)],
            [NSValue valueWithCGSize:CGSizeMake(38, 38)],
            ];
        [sharedAccountManagerInstance configureFIC];
    });
    return sharedAccountManagerInstance;
}

- (void)configureFIC
{
    NSMutableArray *mutableImageFormats = [NSMutableArray array];
    
    for (NSValue *value in self.FICDPhotoSquareImageSizes) {
        CGSize size = [value CGSizeValue];
        // Square image formats...
        NSInteger squareImageFormatMaximumCount = 1000;
        FICImageFormatDevices squareImageFormatDevices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
        
        // ...32-bit BGR
        NSString *formatName = [NSString stringWithFormat:FICDPhotoSquareImage32BitBGRAFormatName, NSStringFromCGSize(size)];
        NSString *formatFamily = [NSString stringWithFormat:FICDPhotoImageFormatFamily, NSStringFromCGSize(size)];
        FICImageFormat *squareImageFormat32BitBGRA = [FICImageFormat formatWithName:formatName family:formatFamily imageSize:size style:FICImageFormatStyle32BitBGRA maximumCount:squareImageFormatMaximumCount devices:squareImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
        
        [mutableImageFormats addObject:squareImageFormat32BitBGRA];
        
        // ...32-bit BGR
        formatName = [NSString stringWithFormat:FICDPhotoSquareImage32BitBGRFormatName, NSStringFromCGSize(size)];
        formatFamily = [NSString stringWithFormat:FICDPhotoImageFormatFamily, NSStringFromCGSize(size)];
        FICImageFormat *squareImageFormat32BitBGR = [FICImageFormat formatWithName:formatName family:formatFamily imageSize:size style:FICImageFormatStyle32BitBGR maximumCount:squareImageFormatMaximumCount devices:squareImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
        
        [mutableImageFormats addObject:squareImageFormat32BitBGR];
        
        // ...16-bit BGR
        formatName = [NSString stringWithFormat:FICDPhotoSquareImage16BitBGRFormatName, NSStringFromCGSize(size)];
        formatFamily = [NSString stringWithFormat:FICDPhotoImageFormatFamily, NSStringFromCGSize(size)];
        FICImageFormat *squareImageFormat16BitBGR = [FICImageFormat formatWithName:formatName family:formatFamily imageSize:size style:FICImageFormatStyle16BitBGR maximumCount:squareImageFormatMaximumCount devices:squareImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
        
        [mutableImageFormats addObject:squareImageFormat16BitBGR];
        
        // ...8-bit Grayscale
        formatName = [NSString stringWithFormat:FICDPhotoSquareImage8BitGrayscaleFormatName, NSStringFromCGSize(size)];
        formatFamily = [NSString stringWithFormat:FICDPhotoImageFormatFamily, NSStringFromCGSize(size)];
        FICImageFormat *squareImageFormat8BitGrayscale = [FICImageFormat formatWithName:formatName family:formatFamily imageSize:size style:FICImageFormatStyle8BitGrayscale maximumCount:squareImageFormatMaximumCount devices:squareImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
        
        [mutableImageFormats addObject:squareImageFormat8BitGrayscale];
        
        if ([UIViewController instancesRespondToSelector:@selector(preferredStatusBarStyle)]) {
            // Pixel image format
            NSInteger pixelImageFormatMaximumCount = 1000;
            FICImageFormatDevices pixelImageFormatDevices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
            
            FICImageFormat *pixelImageFormat = [FICImageFormat formatWithName:FICDPhotoPixelImageFormatName family:FICDPhotoImageFormatFamily imageSize:FICDPhotoPixelImageSize style:FICImageFormatStyle32BitBGR
                                                                 maximumCount:pixelImageFormatMaximumCount devices:pixelImageFormatDevices protectionMode:FICImageFormatProtectionModeNone];
            
            [mutableImageFormats addObject:pixelImageFormat];
        }
        
    }
    
    // Configure the image cache
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache setDelegate:self];
    [sharedImageCache setFormats:mutableImageFormats];
}

- (CGRect)screenPortraitBounds
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (bounds.size.height > bounds.size.width) {
        return bounds;
    }
    return CGRectMake(0, 0, bounds.size.height, bounds.size.width);
}

- (NSString *)getFormatNameWithSize:(CGSize)size style:(FICImageFormatStyle)style
{
    if (![self.FICDPhotoSquareImageSizes containsObject:[NSValue valueWithCGSize:size]]) {
        return nil;
    }
    switch (style) {
        case FICImageFormatStyle32BitBGRA:
            return [NSString stringWithFormat:FICDPhotoSquareImage32BitBGRAFormatName, NSStringFromCGSize(size)];
            break;
        case FICImageFormatStyle32BitBGR:
            return [NSString stringWithFormat:FICDPhotoSquareImage32BitBGRFormatName, NSStringFromCGSize(size)];
            break;
        case FICImageFormatStyle16BitBGR:
            return [NSString stringWithFormat:FICDPhotoSquareImage16BitBGRFormatName, NSStringFromCGSize(size)];
            break;
        case FICImageFormatStyle8BitGrayscale:
            return [NSString stringWithFormat:FICDPhotoSquareImage8BitGrayscaleFormatName, NSStringFromCGSize(size)];
            break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark - FICImageCacheDelegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    // Images typically come from the Internet rather than from the app bundle directly, so this would be the place to fire off a network request to download the image.
    // For the purposes of this demo app, we'll just access images stored locally on disk.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *sourceImage = [(FICDPhoto *)entity sourceImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sourceImage);
        });
    });
}

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity {
    return NO;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage {
    NSLog(@"errorDidOccurWithMessage:%@", errorMessage);
}

@end
