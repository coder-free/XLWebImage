//
//  FICManager.h
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/15.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastImageCache.h"

@interface FICManager : NSObject

@property (nonatomic, strong) NSArray *FICDPhotoSquareImageSizes;

+ (FICManager *)sharedManager;

- (NSString *)getFormatNameWithSize:(CGSize)size style:(FICImageFormatStyle)style;

@end
