//
//  XLImageCache.m
//  ImageResizeDemo
//
//  Created by ZhangBinfeng on 15/10/20.
//  Copyright © 2015年 ZhangBinfeng. All rights reserved.
//

#import "XLImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "FICDPhoto+FormatName.h"
#import "XLGIFImage.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

static dispatch_queue_t xl_cache_global_queue() {
    static dispatch_queue_t xl_cache_global_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xl_cache_global_queue = dispatch_queue_create("com.wou8.xl_image_cache-global", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return xl_cache_global_queue;
}

@interface XLImageCache ()

@end

@implementation XLImageCache

+ (XLImageCache *)sharedCache
{
    static XLImageCache *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

+ (void)cacheDataToDisk:(NSData *)data forURLString:(NSString *)urlString
{
    if (!urlString) {
        return;
    }
    [[self sharedCache] cacheDataToDisk:data forURLString:urlString];
}

+ (BOOL)isCachedToDiskWithURLString:(NSString *)urlString
{
    if (!urlString) {
        return NO;
    }
    return [[self sharedCache] isCachedToDiskWithURLString:urlString];
}

+ (void)cacheImageToMemmary:(UIImage *)image forURLString:(NSString *)urlString
{
    if (!urlString) {
        return;
    }
    [[self sharedCache] cacheImageToMemmary:image forURLString:urlString];
}

+ (void)removeImageForURLString:(NSString *)urlString removeDisk:(BOOL)removeDisk
{
    if (!urlString) {
        return;
    }
    [[self sharedCache] removeImageForURLString:urlString removeDisk:removeDisk];
}

+ (void)removeAllImageFromMemory
{
    [[self sharedCache] removeAllImageFromMemory];
    
}

+ (void)removeAllImageFromMemoryAndDisk
{
    [[self sharedCache] removeAllImageFromMemoryAndDisk];
    
}

+ (void)removeAllImageFromDisk
{
    [[self sharedCache] removeAllImageFromDisk];
}

+ (void)getImageWithURLString:(NSString *)urlString finished:(XLGetImageBlock)finished
{
    if (!urlString) {
        return;
    }
    [[self sharedCache] getCachedImageWithURLString:urlString FICEntity:nil finished:^(UIImage *image, id<FICEntity> entity) {
        if (finished) {
            finished(image);
        }
    }];
}

+ (BOOL)getImageWithURLString:(NSString *)urlString FICEntity:(id<FICEntity>)entity finished:(XLGetImageEntityBlock)finished
{
    if (!urlString) {
        return NO;
    }
    return [[self sharedCache] getCachedImageWithURLString:urlString FICEntity:entity finished:finished];
}

+ (NSData *)getImageDataWithURLString:(NSString *)urlString
{
    if (!urlString) {
        return nil;
    }
    return [[self sharedCache] getImageDataWithURLString:urlString];
}

+ (NSInteger)getSize
{
    return [[self sharedCache] getSize];
}

- (void)cacheDataToDisk:(NSData *)data forURLString:(NSString *)urlString
{
    NSString *key = [self getKeyWithString:urlString];
    [self saveImageToDisk:data key:key];
}
    
- (BOOL)isCachedToDiskWithURLString:(NSString *)urlString
{
    NSString *key = [self getKeyWithString:urlString];
    NSString *path = [self getPathWithKey:key];
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

- (void)cacheImageToMemmary:(UIImage *)image forURLString:(NSString *)urlString
{
    if (image) {
        NSString *key = [self getKeyWithString:urlString];
        [self setObject:image forKey:key];
    }
}

- (void)removeImageForURLString:(NSString *)urlString removeDisk:(BOOL)removeDisk
{
    NSString *key = [self getKeyWithString:urlString];
    [self removeObjectForKey:key];
    if (removeDisk) {
        NSString *path = [self getPathWithKey:key];
        [self removeFile:path];
    }
}

- (void)removeAllImageFromMemory
{
    [self removeAllObjects];
}

- (void)removeAllImageFromMemoryAndDisk
{
    [self removeAllImageFromMemory];
    [self removeAllImageFromDisk];
}

- (void)removeAllImageFromDisk
{
    NSString *imageDir = [self getCacheDir];
    [self removeFile:imageDir];
}

- (BOOL)getCachedImageWithURLString:(NSString *)urlString FICEntity:(id<FICEntity>)entity finished:(XLGetImageEntityBlock)finished
{
    BOOL isCached = [self isCachedToDiskWithURLString:urlString];
    if (!isCached) {
        if ([[NSThread currentThread] isMainThread]) {
            if (finished) {
                finished(nil, entity);
            }
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (finished) {
                    finished(nil, entity);
                }
            });
        }
        return isCached;
    }
    if (entity) {
        FICDPhoto *photo = (FICDPhoto *)entity;
        NSString *key = [self getKeyWithString:urlString];
        NSString *path = [self getPathWithKey:key];
        photo.sourceImageURL = [NSURL URLWithString:path];
        [[FICImageCache sharedImageCache] retrieveImageForEntity:entity withFormatName:[photo formatName] completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
            // This completion block may be called much later. We should check to make sure this cell hasn't been reused for different photos before displaying the image that has loaded.
            if (finished) {
                finished(image, entity);
            }
        }];
    } else {
        NSString *key = [self getKeyWithString:urlString];
        if (finished) {
            id obj = [self objectForKey:key];
            if (obj) {
                if ([[NSThread currentThread] isMainThread]) {
                    finished(obj, entity);
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        finished(obj, entity);
                    });
                }
                return isCached;
            }
            dispatch_async(xl_cache_global_queue(), ^{
                id obj = [self getImageFromDiskWithKey:key];
                if (obj) {
                    [self setObject:obj forKey:key];
                }
                if ([[NSThread currentThread] isMainThread]) {
                    finished(obj, entity);
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        finished(obj, entity);
                    });
                }
            });
        }
    }
    return isCached;
}

- (void)saveImageToDisk:(NSData *)data key:(NSString *)key
{
    NSString *path = [self getPathWithKey:key];
    BOOL success = [data writeToFile:path atomically:YES];
    if (success) {
        NSLog(@"save success");
    }
}

- (UIImage *)getImageFromDiskWithKey:(NSString *)key
{
    NSString *path = [self getPathWithKey:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        if ([[path pathExtension] isEqualToString:@"gif"]) {
            return [XLGIFImage animatedImageWithXLGIFData:data];
        } else {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (!image) {
                NSFileManager *fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:path]) {
                    [fm removeItemAtPath:path error:nil];
                }
            }
            return image;
        }
    } else {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
        }
    }
    return nil;
}

- (NSData *)getImageDataWithURLString:(NSString *)urlString
{
    NSString *key = [self getKeyWithString:urlString];
    NSString *path = [self getPathWithKey:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (NSUInteger)getSize {
    NSUInteger size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self getCacheDir]];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [[self getCacheDir] stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (NSString *)getPathWithKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@/%@", [self getCacheDir], key];
}

- (NSString *)getCacheDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *dir = [NSString stringWithFormat:@"%@/XLImageCache/%@", cacheDir, identifier];
    BOOL isDir;
    if ([fm fileExistsAtPath:dir isDirectory:&isDir]) {
        if (isDir) {
            return dir;
        } else {
            [fm removeItemAtPath:dir error:nil];
        }
    }
    [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (void)removeFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)getKeyWithString:(NSString *)string
{
    NSString *key = [self md5:string];
    if ([[string pathExtension] isEqualToString:@"gif"]) {
        key = [NSString stringWithFormat:@"%@.gif", key];
    }
    return key;
}

//md5 16位加密 （大写）

-(NSString *)md5:(NSString *)str {
    if (!str) {
        return nil;
    }
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end
