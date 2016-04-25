//
//  ViewController.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/4/22.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "ViewController.h"
#import "showView.h"
#import "HCoreText.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    showView *view =  [[showView alloc]initWithFrame:CGRectMake(5, 50, 365, 500)];
    view.backgroundColor =[UIColor whiteColor];
    FrameParserConfig *config = [FrameParserConfig defaultConfig];
    config.textColor = [UIColor blueColor];
    config.autoAdjustHeight = 1;
    NSString *content =@"@爱上无名氏<font name=\"Futura\" size=\"20\" color=\"blue\" >Love <font name=\"Futura\" size=\"12\" color=\"red\">A<image src=\"\" width=\"\" height=\"\">you  I believe that Anything is possible 10 to buy, but to the 19 today or generation of packaging, had love who know why ah?Please ask!<font name=\"Futura\" size=\"25\">";
    CoretextData *coreData =[FrameParser parserWithPropertyContent:content contentSize:view.bounds.size defaultConfig:config useingParameters:^NSArray *(SourceType type, NSString *argumentString) {
        NSLog(@"%@",argumentString);
        NSLog(@"======================");
        return @[@"name",@"size",@"color"];
    }];
//    coreData = [FrameParser parserWithPropertyContent:content contentSize:view.bounds.size defaultConfig:config];
    [self.view addSubview:view];
    [view drawWithCoretextData:coreData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

