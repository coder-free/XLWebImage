//
//  FICDPhoto+FormatName.m
//  HanfotoiPhone
//
//  Created by zbf on 16/5/23.
//  Copyright © 2016年 com.snbw. All rights reserved.
//

#import "FICDPhoto+FormatName.h"
#import <objc/runtime.h>

static const void *FICDPhotoFormatNameKey = &FICDPhotoFormatNameKey;

@implementation FICDPhoto (FormatName)

@dynamic formatName;

- (NSObject *)formatName {
    return objc_getAssociatedObject(self, FICDPhotoFormatNameKey);
}

- (void)setFormatName:(NSObject *)formatName {
    [self willChangeValueForKey:@"formatName"];
    objc_setAssociatedObject(self, FICDPhotoFormatNameKey, formatName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"formatName"];
}

@end
