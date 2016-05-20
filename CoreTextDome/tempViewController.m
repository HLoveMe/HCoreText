//
//  tempViewController.m
//  CoreTextDome
//
//  Created by space on 16/4/26.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "tempViewController.h"
#import "HCoreText.h"
#import <objc/runtime.h>

@interface tempViewController()<CTViewTouchDelegate>
@end
@implementation tempViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    CTDrawView *view =  [[CTDrawView alloc]initWithFrame:CGRectMake(5, 200, 365, 400)];
//    view.delegate =  self;
//    view.backgroundColor = [UIColor grayColor];
//    FrameParserConfig *config = [FrameParserConfig defaultConfigWithContentSize:view.bounds.size];
//    config.autoAdjustHeight = 1;
//    NSString *url= @"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg";
//    
//    NSString *content =[NSString stringWithFormat:@" 一  切   皆  有  可 能<text>爱上无名氏<link url=\"http://www.baidu.com\" namea=\"Futura\" size=\"30\" color=\"blue\" ><image srac=\"%@\" width=\"200\" height=\"120\">Love ***无名氏个大傻逼<text name=\"Futura\" size=\"12\" color=\"red\">you  I believe that Anything is possible 10 to CoreTextDome, but to the 19 today or generation of packaging, had love who know why ah?Please ask!<text name=\"Futura\">",url];
//    CoreTextData *data = [FrameParser parserWithPropertyContent:content defaultCfg:config];
//    [view drawWithCoreTextData:data];
//    [view setBeginTouchEvent:YES];
//    [self.view addSubview:view];
//    
//    return;
    
    CTDrawView *view2 = [[CTDrawView alloc]initWithFrame:CGRectMake(5, 250, 365, 1000)];
    view2.backgroundColor= [UIColor grayColor];
    view2.delegate=self;
    
    FrameParserConfig *config2 = [FrameParserConfig defaultConfigWithContentSize:view2.bounds.size];
    config2.autoAdjustHeight = 1;
    
    CoreTextData *coreD = [FrameParser parserWithSource:[self getContent] defaultCfg:config2];
    [view2 drawWithCoreTextData:coreD];
    [self.view addSubview:view2];
}

#pragma -mark CTViewTouchDelegate
-(void)touchView:(UIView *)view contentString:(NSString *)content{
    NSLog(@"%@",content);
}
-(UIColor *)touchView:(UIView *)view contentString:(NSString *)content URLString:(NSString *)urlString{
    NSLog(@"%@",content);
    NSLog(@"%@",urlString);
    return [UIColor orangeColor];
}
-(void)touchView:(UIView *)view imageName:(NSString *)source{
    NSLog(@"%@",source);
    UIImageView * one = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [self.view addSubview:one];
    [HImageBox getImageWithSource:source option:^(UIImage *img, BOOL isFirst) {
        [one setImage:img];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [one removeFromSuperview];
    });
}









-(NSArray *)getContent{

    NSArray *contentArr = @[
                            @{
                                @"content":@"@爱上无名氏 :x::x::o::o:",
                                @"type":@"link",
                                @"url":@"http://www.baidu.com",
                                @"size":@"18",
                                @"color":@"red",
                                @"underLine":@"Single",
                                @"underColor":@"black",
                                @"name":@"Futura"
                                },
                            @{
                                @"content":@"",
                                @"type":@"image",
                                @"src":@"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg",
                                @"width":@"200",
                                @"height":@"120"
                                },
                            @{
                                @"content":@":+1: I love you 无名氏个大傻逼",
                                @"type":@"text",
                                @"color":@"blue",
                                @"size":@"18",
                                @"name":@"Futura"
                                }
                            ];
    return contentArr;
}


@end
