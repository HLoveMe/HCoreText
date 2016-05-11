//
//  tempViewController.m
//  CoreTextDome
//
//  Created by space on 16/4/26.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "tempViewController.h"
#import "HCoreText.h"
#import "HImageBox.h"
@interface tempViewController()<CTViewTouchDelegate>
@end
@implementation tempViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CTDrawView *view =  [[CTDrawView alloc]initWithFrame:CGRectMake(5, 80, 365, 400)];
    view.delegate =  self;
    view.backgroundColor = [UIColor grayColor];
    FrameParserConfig *config = [FrameParserConfig defaultConfigWithContentSize:view.bounds.size];
    config.autoAdjustHeight = 1;
    NSString *url= @"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg";
    
    NSString *content =[NSString stringWithFormat:@"<image src=\"%@\" width=\"200\" height=\"120\">@XXOO<font name=\"Futura\" size=\"20\" color=\"blue\" >Love T&^朱子豪*四)个大傻逼<font name=\"Futura\" size=\"12\" color=\"red\">you  I believe that Anything is possible 10 to CoreTextDome, but to the 19 today or generation of packaging, had love who know why ah?Please ask!<font name=\"Futura\" size=\"12\">",url];
    CoreTextData *data = [FrameParser parserContent:content defaultCfg:config];
    [view drawWithCoreTextData:data];
    [view setBeginTouchEvent:YES];
    [self.view addSubview:view];
    
}

#pragma -mark CTViewTouchDelegate
-(void)touchView:(UIView *)view contentRange:(NSRange)range contentString:(NSString *)content attributes:(NSMutableDictionary *)attribute{
    NSLog(@"%@",NSStringFromRange(range));
    NSLog(@"%@",content);
    NSLog(@"%@",attribute);
//    attribute[NSForegroundColorAttributeName] = (__bridge id _Nullable)([UIColor orangeColor].CGColor);
}
-(void)touchView:(UIView *)view contentRange:(NSRange)range imageName:(NSString *)source{
    NSLog(@"%@",NSStringFromRange(range));
    NSLog(@"%@",source);
    
}
@end
