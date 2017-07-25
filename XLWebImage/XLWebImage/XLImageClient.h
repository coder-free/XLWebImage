//
//  XLImageClient.h
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/20.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XLProgressBlock)(CGFloat progress, NSString *urlString);
typedef void(^XLFinishedBlock)(UIImage *image, NSString *urlString);
typedef void(^XLDataFinishedBlock)(NSData *data, NSString *urlString);

@interface XLImageClient : NSObject

+ (void)loadImageWithURLString:(NSString *)urlString finished:(XLFinishedBlock)finished;

+ (void)loadImageWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress finished:(XLFinishedBlock)finished;

+ (void)loadImageDataWithURLString:(NSString *)urlString finished:(XLDataFinishedBlock)finished;

+ (void)loadImageDataWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress finished:(XLDataFinishedBlock)finished;

@end
