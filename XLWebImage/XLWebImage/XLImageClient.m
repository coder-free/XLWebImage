
//  XLImageClient.m
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/20.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import "XLImageClient.h"
#import <objc/runtime.h>
#import "UIImageView+XLWebLoad.h"
#import "XLImageCache.h"
#import "FICManager.h"
#import "FICDPhoto+FormatName.h"
#import "XLGIFImage.h"

static dispatch_queue_t xl_client_global_queue() {
    static dispatch_queue_t xl_client_global_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xl_client_global_queue = dispatch_queue_create("com.wou8.xl_image_client-global", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return xl_client_global_queue;
}

@interface XLImageClient() <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableSet *urlSet;

@property (nonatomic, strong) NSMapTable *urlDataFinishBlockMap;

@property (nonatomic, strong) NSMapTable *urlProgressBlockMap;

@property (nonatomic, strong) NSMapTable *urlFinishBlockMap;

@property (nonatomic, strong) NSMapTable *urlTaskMap;

@property (nonatomic, strong) NSOperationQueue *clientGlobalQueue;

@end

@implementation XLImageClient

+ (XLImageClient *)sharedClient
{
    static XLImageClient *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clientGlobalQueue = [[NSOperationQueue alloc] init];
        self.clientGlobalQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *c = [NSURLSessionConfiguration defaultSessionConfiguration];
        c.HTTPMaximumConnectionsPerHost = 10;
        _session = [NSURLSession sessionWithConfiguration:c delegate:self delegateQueue:self.clientGlobalQueue];
    }
    return _session;
}

- (NSMutableSet *)urlSet
{
    if (!_urlSet) {
        _urlSet = [[NSMutableSet alloc] init];
    }
    return _urlSet;
}

- (NSMapTable *)urlFinishBlockMap
{
    if (!_urlFinishBlockMap) {
        _urlFinishBlockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _urlFinishBlockMap;
}

- (NSMapTable *)urlDataFinishBlockMap
{
    if (!_urlDataFinishBlockMap) {
        _urlDataFinishBlockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _urlDataFinishBlockMap;
}

- (NSMapTable *)urlProgressBlockMap
{
    if (!_urlProgressBlockMap) {
        _urlProgressBlockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _urlProgressBlockMap;
}

- (NSMapTable *)urlTaskMap
{
    if (!_urlTaskMap) {
        _urlTaskMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _urlTaskMap;
}

#pragma mark - Image

+ (void)loadImageWithURLString:(NSString *)urlString finished:(XLFinishedBlock)finished
{
    [[self sharedClient] loadImageWithURLString:urlString progress:nil finished:finished];
}

+ (void)loadImageWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress finished:(XLFinishedBlock)finished
{
    [[self sharedClient] loadImageWithURLString:urlString progress:progress finished:finished];
}

- (void)loadImageWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress finished:(XLFinishedBlock)finished
{
    __weak typeof(self) wself = self;
    [XLImageCache getImageWithURLString:urlString finished:^(UIImage *image) {
        if (!image) {
            [wself loadDataWithURLString:urlString progress:progress finished:^(NSData *data, NSString *urlString) {
                if (data) {
                    dispatch_async(xl_client_global_queue(), ^{
                        if (finished) {
                            UIImage *image;
                            if ([[urlString pathExtension] isEqualToString:@"gif"]) {
                                image = [XLGIFImage animatedImageWithXLGIFData:data];
                            } else {
                                image = [[UIImage alloc] initWithData:data];
                            }
                            [XLImageCache cacheImageToMemmary:image forURLString:urlString];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                finished(image, urlString);
                            });
                        }
                    });
                } else {
                    if (finished) {
                        finished(nil, urlString);
                    }
                }
            }];
        } else {
            if (progress) {
                progress(1, urlString);
            }
            if (finished) {
                finished(image, urlString);
            }
        }
    }];
}

+ (void)loadImageWithURLString:(NSString *)urlString imageView:(UIImageView *)imageView
{
    [[self sharedClient] loadImageWithURLString:urlString imageView:imageView];
}

- (void)loadImageWithURLString:(NSString *)urlString imageView:(UIImageView *)imageView
{
    __weak typeof(self) wself = self;
    if ([XLImageCache isCachedToDiskWithURLString:urlString]) {
        [wself getCachedImageWithURLString:urlString imageView:imageView];
    } else {
        dispatch_async(xl_client_global_queue(), ^{
            [wself loadDataWithURLString:urlString progress:^(CGFloat progress, NSString *urlString) {
                if (imageView && imageView.progressBlock && [imageView.urlString isEqualToString:urlString]) {
                    imageView.progressBlock(progress, urlString);
                }
            } finished:^(NSData *data, NSString *urlString) {
                [wself getCachedImageWithURLString:urlString imageView:imageView];
            }];
        });
    }
    return;
}

- (void)getCachedImageWithURLString:(NSString *)urlString imageView:(UIImageView *)imageView
{
    FICDPhoto *photo = nil;
    if ([XLWebImageCommon fastImageCacheEnabled] && ![[urlString pathExtension] isEqualToString:@"gif"]) {
        NSString *formatName = [[FICManager sharedManager] getFormatNameWithSize:imageView.frame.size style:FICImageFormatStyle32BitBGR];
        if (formatName) {
            photo = [[FICDPhoto alloc] init];
            photo.formatName = formatName;
        }
    }
    [XLImageCache getImageWithURLString:urlString FICEntity:photo finished:^(UIImage *image, id<FICEntity> entity) {
        if (image && imageView.finishedBlock && [imageView.urlString isEqualToString:urlString]) {
            imageView.finishedBlock(image, urlString);
        }
    }];
}

#pragma mark - Data

+ (void)loadImageDataWithURLString:(NSString *)urlString finished:(XLDataFinishedBlock)finished
{
    [[self sharedClient] loadDataWithURLString:urlString progress:nil finished:finished];
}

+ (void)loadImageDataWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress finished:(XLDataFinishedBlock)finished
{
    [[self sharedClient] loadDataWithURLString:urlString progress:progress finished:finished];
}

- (void)loadDataWithURLString:(NSString *)urlString progress:(XLProgressBlock)progress finished:(XLDataFinishedBlock)finished
{
    if (!urlString) {
        return;
    }
    __weak typeof(self) wself = self;
    if ([[NSThread currentThread] isMainThread]) {
        if (progress) {
            progress(0, urlString);
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(0, urlString);
            }
        });
    }
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [XLImageCache getImageDataWithURLString:urlString];
        if (data) {
            if ([[NSThread currentThread] isMainThread]) {
                if (progress) {
                    progress(1, urlString);
                }
                if (finished) {
                    finished(data, urlString);
                }
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (progress) {
                        progress(1, urlString);
                    }
                    if (finished) {
                        finished(data, urlString);
                    }
                });
            }
            return;
        }
        //progress
        if (progress) {
            if (![wself.urlProgressBlockMap objectForKey:urlString]) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [wself.urlProgressBlockMap setObject:array forKey:urlString];
            }
            NSMutableArray *urlProgressBlockes = [wself.urlProgressBlockMap objectForKey:urlString];
            [urlProgressBlockes addObject:progress];
        }
        //data
        if (finished) {
            if (![wself.urlDataFinishBlockMap objectForKey:urlString]) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [wself.urlDataFinishBlockMap setObject:array forKey:urlString];
            }
            NSMutableArray *urlDataFinishBlockes = [wself.urlDataFinishBlockMap objectForKey:urlString];
            [urlDataFinishBlockes addObject:finished];
        }
        //url
        if ([wself.urlSet containsObject:urlString]) {
            return;
        }
        [wself.urlSet addObject:urlString];
        //task
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        NSURLSessionDownloadTask *task = [[XLImageClient sharedClient].session downloadTaskWithRequest:request];
        [task resume];
        NSLog(@"loadImageWithURLString:%@", urlString);
        [wself.urlTaskMap setObject:task forKey:urlString];
    }];
    [wself.clientGlobalQueue addOperation:operation];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    NSLog(@"didFinishDownloadingToURL:%@", location);
    if (data) {
        NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
        [XLImageCache cacheDataToDisk:data forURLString:urlString];
        NSMutableArray *urlDataFinishBlockes = [self.urlDataFinishBlockMap objectForKey:urlString];
        for (XLDataFinishedBlock block in urlDataFinishBlockes) {
            if (block) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(data, urlString);
                });
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat p = totalBytesWritten * 1.0f / totalBytesExpectedToWrite;
    NSLog(@"progress:%f",p);
    NSString *urlString = downloadTask.currentRequest.URL.absoluteString;
    NSMutableArray *urlProgressBlockes = [self.urlProgressBlockMap objectForKey:urlString];
    for (XLProgressBlock progress in urlProgressBlockes) {
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(p, urlString);
            });
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"didCompleteWithError:%@", error);
    NSString *urlString = task.currentRequest.URL.absoluteString;
    [self.urlProgressBlockMap removeObjectForKey:urlString];
    [self.urlDataFinishBlockMap removeObjectForKey:urlString];
    [self.urlSet removeObject:urlString];
}

@end
