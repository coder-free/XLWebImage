//
//  XLWebImageTools.m
//  XLWebImage
//
//  Created by zbf on 16/5/24.
//  Copyright © 2016年 com.xl. All rights reserved.
//

#import "XLWebImageCommon.h"

static BOOL fastImageCacheEnabled = NO;

static UIColor *webImageProgressPrimaryColor = nil;

static UIColor *webImageProgressSecondaryColor = nil;

static BOOL xl_autoPlayGif = NO;

static NSInteger xl_gifRepeatCount = 1;

static XLWebImageProgressStyle webImageProgressStyle = XLWebImageProgressStyleNone;

@implementation XLWebImageCommon

+ (void)load
{
    [super load];
    webImageProgressPrimaryColor = [UIColor darkGrayColor];
    webImageProgressSecondaryColor = [UIColor darkGrayColor];
}

+ (BOOL)fastImageCacheEnabled
{
    return fastImageCacheEnabled;
}

+ (void)setFastImageCacheEnabled:(BOOL)enabled
{
    fastImageCacheEnabled = enabled;
}

+ (UIColor *)progressPrimaryColor
{
    return webImageProgressPrimaryColor;
}

+ (void)setProgressPrimaryColor:(UIColor *)color
{
    webImageProgressPrimaryColor = color;
}

+ (UIColor *)progressSecondaryColor
{
    return webImageProgressSecondaryColor;
}

+ (void)setProgressSecondaryColor:(UIColor *)color
{
    webImageProgressSecondaryColor = color;
}

+ (XLWebImageProgressStyle)progressStyle
{
    return webImageProgressStyle;
}

+ (void)setProgressStyle:(XLWebImageProgressStyle)progressStyle
{
    webImageProgressStyle = progressStyle;
}

+ (BOOL)autoPlayGif;//default  NO
{
    return xl_autoPlayGif;
}

+ (void)setAutoPlayGif:(BOOL)autoPlayGif;
{
    xl_autoPlayGif = autoPlayGif;
}

+ (NSInteger)gifRepeatCount;//default  1
{
    return xl_gifRepeatCount;
}

+ (void)setGifRepeatCount:(BOOL)gifRepeatCount;
{
    xl_gifRepeatCount = gifRepeatCount;
}

@end
