//
//  XLGIFImage.h
//  XLWebImage
//
//  Created by zbf on 2017/7/10.
//  Copyright © 2017年 com.xl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLGIFImage : UIImage

+ (UIImage * _Nullable)animatedImageWithXLGIFData:(NSData * _Nonnull)theData;

+ (UIImage * _Nullable)animatedImageWithXLGIFURL:(NSURL * _Nonnull)theURL;

@end
