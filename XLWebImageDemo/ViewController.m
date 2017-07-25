//
//  ViewController.m
//  XLWebImageDemo
//
//  Created by zbf on 16/5/24.
//  Copyright © 2016年 com.xl. All rights reserved.
//

#import "ViewController.h"
#import <XLWebImage/XLWebImage.h>
#import "DemoObject.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.queue = [[NSOperationQueue alloc] init];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [XLImageCache removeImageForURLString:@"http://imgsrc.baidu.com/baike/pic/item/0b46f21fbe096b6329270c190c338744ebf8acb9.jpg" removeDisk:YES];
    [self.imageView setImageWithURLString:@"http://imgsrc.baidu.com/baike/pic/item/0b46f21fbe096b6329270c190c338744ebf8acb9.jpg"];
    DemoObject *demo = [[DemoObject alloc] init];
    NSLog(@"demo - init");
    NSOperation *publishOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"publishOperation-start");
        while (1) {
            [NSThread sleepForTimeInterval:1];
            break;
        }
        [demo test];
        NSLog(@"publishOperation-finish");
    }];
    [[[NSOperationQueue alloc] init] addOperation:publishOperation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
