//
//  UIImageView+XLWebLoad.h
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/20.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLImageClient.h"
#import "XLWebImageCommon.h"

@interface UIImageView (XLWebLoad)

@property (nonatomic, copy, readonly) NSString *urlString;

@property (nonatomic, strong) UIColor *progressPrimaryColor;

@property (nonatomic, strong) UIColor *progressSecondaryColor;

@property (nonatomic) XLWebImageProgressStyle progressStyle;

@property (nonatomic, strong, readonly) UIView *progressView;

@property (nonatomic, strong, readonly) XLProgressBlock progressBlock;

@property (nonatomic, strong, readonly) XLFinishedBlock finishedBlock;

@property (nonatomic) BOOL hideProgressView;

- (void)setImageWithURLString:(NSString *)urlString;

- (void)setImageWithURLString:(NSString *)urlString placeholder:(NSString *)placeholder;

- (void)setImageWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress;

- (void)setImageWithURLString:(NSString *)urlString placeholder:(NSString *)placeholder progress:(XLProgressBlock)progress;

#pragma mark - SDWebImage

typedef void(^XL_SDWebImageCompletedBlock)(UIImage *image, NSError *error, NSInteger cacheType);

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(NSInteger)options;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(NSInteger)options completed:(XL_SDWebImageCompletedBlock)completedBlock;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(XL_SDWebImageCompletedBlock)completedBlock;

@end
