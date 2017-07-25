//
//  UIImageView+XLWebLoad.m
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/20.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import "UIImageView+XLWebLoad.h"
#import <objc/runtime.h>
#import <M13ProgressSuite/M13ProgressSuite.h>

static const void *urlStringKey = &urlStringKey;

static const void *hideProgressViewKey = &hideProgressViewKey;

static const void *progressViewKey = &progressViewKey;

static const void *progressBlockKey = &progressBlockKey;

static const void *finishedBlockKey = &finishedBlockKey;

static const void *progressPrimaryColorKey = &progressPrimaryColorKey;

static const void *progressSecondaryColorKey = &progressSecondaryColorKey;

static const void *xlprogressStyleKey = &xlprogressStyleKey;

@interface XLImageClient (LoadWithImageView)

+ (void)loadImageWithURLString:(NSString *)urlString imageView:(UIImageView *)imageView;

@end

@implementation UIImageView (XLWebLoad)

@dynamic urlString;
@dynamic hideProgressView;
@dynamic progressView;
@dynamic progressBlock;
@dynamic finishedBlock;
@dynamic progressPrimaryColor;
@dynamic progressSecondaryColor;
@dynamic progressStyle;

- (XLWebImageProgressStyle)progressStyle
{
    return (XLWebImageProgressStyle)[objc_getAssociatedObject(self, xlprogressStyleKey) integerValue];
}

- (void)setProgressStyle:(XLWebImageProgressStyle)progressStyle
{
    [self willChangeValueForKey:@"progressStyle"];
    objc_setAssociatedObject(self, xlprogressStyleKey, @(progressStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"progressStyle"];
}

- (UIColor *)progressPrimaryColor
{
    return objc_getAssociatedObject(self, progressPrimaryColorKey);
}

- (void)setProgressPrimaryColor:(UIColor *)progressPrimaryColor
{
    [self willChangeValueForKey:@"progressPrimaryColor"];
    objc_setAssociatedObject(self, progressPrimaryColorKey, progressPrimaryColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"progressPrimaryColor"];
}

- (UIColor *)progressSecondaryColor
{
    return objc_getAssociatedObject(self, progressSecondaryColorKey);
}

- (void)setProgressSecondaryColor:(UIColor *)progressSecondaryColor
{
    [self willChangeValueForKey:@"progressSecondaryColor"];
    objc_setAssociatedObject(self, progressSecondaryColorKey, progressSecondaryColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"progressSecondaryColor"];
}

- (void)setUrlString:(NSString *)urlString
{
    [self willChangeValueForKey:@"urlString"];
    objc_setAssociatedObject(self, urlStringKey, urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"urlString"];
}

- (NSString *)urlString
{
    return objc_getAssociatedObject(self, urlStringKey);
}

- (UIView *)progressView
{
    return objc_getAssociatedObject(self, progressViewKey);
}

- (void)setProgressView:(UIView *)progressView
{
    [self willChangeValueForKey:@"progressView"];
    objc_setAssociatedObject(self, progressViewKey, progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"progressView"];
}

- (BOOL)hideProgressView
{
    return [objc_getAssociatedObject(self, hideProgressViewKey) boolValue];
}

- (void)setHideProgressView:(BOOL)hideProgressView
{
    [self willChangeValueForKey:@"showpProgressView"];
    objc_setAssociatedObject(self, hideProgressViewKey, [NSNumber numberWithBool:hideProgressView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"showpProgressView"];
}

- (XLProgressBlock)progressBlock
{
    return objc_getAssociatedObject(self, progressBlockKey);
}

- (void)setProgressBlock:(XLProgressBlock)progressBlock
{
    [self willChangeValueForKey:@"progressBlock"];
    objc_setAssociatedObject(self, progressBlockKey, progressBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"progressBlock"];
}

- (XLFinishedBlock)finishedBlock
{
    return objc_getAssociatedObject(self, finishedBlockKey);
}

- (void)setFinishedBlock:(XLFinishedBlock)finishedBlock
{
    [self willChangeValueForKey:@"finishedBlock"];
    objc_setAssociatedObject(self, finishedBlockKey, finishedBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"finishedBlock"];
}

- (void)setImageWithURLString:(NSString *)urlString
{
    [self setImageWithURLString:urlString placeholder:nil progress:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholder:(NSString *)placeholder
{
    [self setImageWithURLString:urlString placeholder:placeholder progress:nil];
}

- (void)setImageWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress
{
    [self setImageWithURLString:urlString placeholder:nil progress:progress];
}

- (void)setImageWithURLString:(NSString *)urlString placeholder:(NSString *)placeholder progress:(XLProgressBlock)progress
{
    UIImage *placeholderImage = nil;
    if (placeholder) {
        placeholderImage = [UIImage imageNamed:placeholder];
    }
    [self setImageWithURLString:urlString placeholderImage:placeholderImage progress:progress];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage progress:(XLProgressBlock)progress
{
    [self setImageWithURLString:urlString placeholderImage:placeholderImage progress:progress completed:nil];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage progress:(XLProgressBlock)progress completed:(XL_SDWebImageCompletedBlock)completedBlock
{
    XLWebImageProgressStyle progressStyle;
    if (self.progressStyle != 0) {
        progressStyle = self.progressStyle;
    } else if ([XLWebImageCommon progressStyle] != 0) {
        progressStyle = [XLWebImageCommon progressStyle];
    } else {
        progressStyle = XLWebImageProgressStyleNone;
    }
    if (![self.urlString isEqualToString:urlString]) {
        if (((progressStyle & XLWebImageProgressStyleImage) && placeholderImage)) {
            [self setImage:nil];
        } else {
            [self setImage:placeholderImage];
        }
    }
    self.urlString = urlString;
    
    __weak typeof (self) wself = self;
    [self setProgressBlock:^(CGFloat progressF, NSString *urlString) {
        if (![urlString isEqualToString:wself.urlString]) {
            return;
        }
        if (progress) {
            progress(progressF, urlString);
        }
        if (!wself.hideProgressView) {
            if (!wself.progressView) {
                M13ProgressView *progressView = nil;
                if (progressStyle != 0 && progressStyle != XLWebImageProgressStyleNone) {
                    CGFloat width;
                    if (MIN(wself.frame.size.width, wself.frame.size.height) > 110) {
                        width = 100;
                    } else {
                        width = MIN(wself.frame.size.width, wself.frame.size.height);
                    }
                    if (progressStyle & XLWebImageProgressStylePie) {
                        progressView = [[M13ProgressViewPie alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                        if (progressStyle & XLWebImageProgressStyleIndeterminate) {
                            progressView.indeterminate = YES;
                        }
                    } else if (progressStyle & XLWebImageProgressStyleRing) {
                        M13ProgressViewRing *progressViewRing = [[M13ProgressViewRing alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                        if (progressStyle & XLWebImageProgressStyleIndeterminate) {
                            progressViewRing.indeterminate = YES;
                        } else if (progressStyle & XLWebImageProgressStylePercent) {
                            progressViewRing.indeterminate = NO;
                            [progressViewRing setShowPercentage:YES];
                        }
                        progressView = progressViewRing;
                    } else if (progressStyle & XLWebImageProgressStyleSegment) {
                        M13ProgressViewSegmentedRing *progressViewSegmentedRing = [[M13ProgressViewSegmentedRing alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                        if (progressStyle & XLWebImageProgressStyleIndeterminate) {
                            progressViewSegmentedRing.indeterminate = YES;
                        } else if (progressStyle & XLWebImageProgressStylePercent) {
                            progressViewSegmentedRing.indeterminate = NO;
                            [progressViewSegmentedRing setShowPercentage:YES];
                        }
                        progressView = progressViewSegmentedRing;
                    } else if ((progressStyle & XLWebImageProgressStyleImage) && placeholderImage) {
                        M13ProgressViewImage *progressViewImage = [[M13ProgressViewImage alloc] initWithFrame:CGRectMake(0, 0, width, width)];
                        progressViewImage.progressImage = placeholderImage;
                        if (progressStyle & XLWebImageProgressStyleBackground) {
                            progressViewImage.drawGreyscaleBackground = YES;
                        } else if (progressStyle & XLWebImageProgressStyleFromBottom) {
                            progressViewImage.progressDirection = M13ProgressViewImageProgressDirectionBottomToTop;
                        } else if (progressStyle & XLWebImageProgressStyleFromLeft) {
                            progressViewImage.progressDirection = M13ProgressViewImageProgressDirectionLeftToRight;
                        } else if (progressStyle & XLWebImageProgressStyleFromTop) {
                            progressViewImage.progressDirection = M13ProgressViewImageProgressDirectionTopToBottom;
                        } else if (progressStyle & XLWebImageProgressStyleFromRight) {
                            progressViewImage.progressDirection = M13ProgressViewImageProgressDirectionRightToLeft;
                        }
                        progressView = progressViewImage;
                    } else {
                        progressView = [[M13ProgressViewRing alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                    }
                }
                if (progressView) {
                    progressView.progress = 0;
                    progressView.primaryColor = wself.progressPrimaryColor?:[XLWebImageCommon progressPrimaryColor];
                    progressView.secondaryColor = wself.progressSecondaryColor?:[XLWebImageCommon progressSecondaryColor];
                    progressView.center = CGPointMake(wself.frame.size.width / 2, wself.frame.size.height / 2);
                    [wself addSubview:progressView];
                    wself.progressView = progressView;
                }
            }
            if (wself.progressView && [wself.progressView respondsToSelector:@selector(setProgress:)]) {
                [wself.progressView performSelector:@selector(setProgress:) withObject:@(progressF)];
            }
        }
    }];
    
    [self setFinishedBlock:^(UIImage *image, NSString *urlString) {
        if (![urlString isEqualToString:wself.urlString]) {
            return;
        }
        
        if ([[NSThread currentThread] isMainThread]) {
            if (wself.progressView) {
                if ([wself.progressView superview]) {
                    [wself.progressView removeFromSuperview];
                }
                wself.progressView = nil;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (wself.progressView) {
                    if ([wself.progressView superview]) {
                        [wself.progressView removeFromSuperview];
                    }
                    wself.progressView = nil;
                }
            });
        }
        if (image) {
            if ([[NSThread currentThread] isMainThread]) {
                if ([[urlString pathExtension] isEqualToString:@"gif"]) {
                    wself.animationImages = image.images;
                    wself.animationDuration = image.duration;
                    wself.animationRepeatCount = [XLWebImageCommon gifRepeatCount];
                    if ([wself.animationImages count] > 0) {
                        [wself setImage:wself.animationImages[0]];
                    }
                    if ([XLWebImageCommon autoPlayGif]) {
                        [wself startAnimating];
                    }
                } else {
                    [wself setImage:image];
                }
                if (completedBlock) {
                    completedBlock(image, nil, 0);
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[urlString pathExtension] isEqualToString:@"gif"]) {
                        wself.animationImages = image.images;
                        wself.animationDuration = image.duration;
                        wself.animationRepeatCount = [XLWebImageCommon gifRepeatCount];
                        if ([wself.animationImages count] > 0) {
                            [wself setImage:wself.animationImages[0]];
                        }
                        if ([XLWebImageCommon autoPlayGif]) {
                            [wself startAnimating];
                        }
                    } else {
                        [wself setImage:image];
                    }
                    if (completedBlock) {
                        completedBlock(image, nil, 0);
                    }
                });
            }
        } else {
            if ([[NSThread currentThread] isMainThread]) {
                if (completedBlock) {
                    completedBlock(nil, [NSError errorWithDomain:@"download error." code:0 userInfo:nil], 0);
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completedBlock) {
                        completedBlock(nil, [NSError errorWithDomain:@"download error." code:0 userInfo:nil], 0);
                    }
                });
            }
        }
    }];
    
    [XLImageClient loadImageWithURLString:urlString imageView:wself];
}

#pragma mark - SDWebImage

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(NSInteger)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(XL_SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(NSInteger)options completed:(XL_SDWebImageCompletedBlock)completedBlock
{
    NSString *urlString = url.absoluteString;
    [self setImageWithURLString:urlString placeholderImage:placeholder progress:nil completed:completedBlock];
}

@end
