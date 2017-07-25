//
//  XLWebImageTools.h
//  XLWebImage
//
//  Created by zbf on 16/5/24.
//  Copyright © 2016年 com.xl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XLWebImageProgressStyle) {
    //main style
    XLWebImageProgressStyleNone = 1<<31,
    XLWebImageProgressStylePie = 1<<0,
    XLWebImageProgressStyleRing = 1<<1,
    XLWebImageProgressStyleSegment = 1<<2,
    XLWebImageProgressStyleImage = 1<<3,
    
    //sub style
    XLWebImageProgressStyleIndeterminate = 1<<4,//适用于 Pie Ring Segment
    XLWebImageProgressStylePercent = 1<<5,//适用于 Ring Segment
    XLWebImageProgressStyleBackground = 1<<6,//适用于 Image
    XLWebImageProgressStyleFromTop = 1<<7,//适用于 Image
    XLWebImageProgressStyleFromBottom = 1<<8,//适用于 Image
    XLWebImageProgressStyleFromLeft = 1<<9,//适用于 Image
    XLWebImageProgressStyleFromRight = 1<<10,//适用于 Image
};

@interface XLWebImageCommon : NSObject

+ (BOOL)fastImageCacheEnabled;//default  NO

+ (void)setFastImageCacheEnabled:(BOOL)enabled;

+ (UIColor *)progressPrimaryColor;//dufault  nil

+ (void)setProgressPrimaryColor:(UIColor *)color;

+ (UIColor *)progressSecondaryColor;//dufault  nil

+ (void)setProgressSecondaryColor:(UIColor *)color;

+ (XLWebImageProgressStyle)progressStyle;//dufault  XLWebImageProgressStyleNone

+ (void)setProgressStyle:(XLWebImageProgressStyle)progressStyle;

+ (BOOL)autoPlayGif;//default  NO

+ (void)setAutoPlayGif:(BOOL)autoPlayGif;

+ (NSInteger)gifRepeatCount;//default  1

+ (void)setGifRepeatCount:(BOOL)gifRepeatCount;

@end
