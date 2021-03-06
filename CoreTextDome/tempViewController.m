//
//  tempViewController.m
//  CoreTextDome
//
//  Created by space on 16/4/26.
//  Copyright © 2016年 朱子豪. All rights reserved.
//
#import "AppDelegate.h"
#import "tempViewController.h"
#import "HCoreText.h"
#import "HVideoPlayView.h"
#import "HImageBox.h"
@interface tempViewController()<CTViewTouchDelegate,HVideoPlayerDelegate>{
    HVideoPlayView *player;
}
@end
@implementation tempViewController

-(void)viewDidLoad{
    [super viewDidLoad];
//
//        [self.view setBackgroundColor:[UIColor whiteColor]];
//        CTDrawView *view =  [[CTDrawView alloc]initWithFrame:CGRectMake(5, 70, 365, 400)];
//        view.backgroundColor=[UIColor grayColor];
//        view.delegate =  self;
//        FrameParserConfig *config = [FrameParserConfig defaultConfigWithContentSize:view.bounds.size];
//        config.integrate=0;
//        config.autoAdjustHeight = 1;
//        NSString *content =[NSString stringWithFormat:@"百度:+1:我<link url=\"http://www.baidu.com\" size=\"20\"><image src=\"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg\" height=100 width=200 isSingleLine=0 isReturn=1> 朱子豪过在算出位置添<text size=12 color=\"red\" >AAA<text><image src=\"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg\" height=100 width=200>\n<image src=\"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg\" height=100 width=200>BBB<text><image src=\"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg\" height=100 width=200>AAA:+1:<text size=18>"];
//        CoreTextData *data = [FrameParser parserWithPropertyContent:content defaultCfg:config];
//        [view drawWithCoreTextData:data];
//        [view setBeginTouchEvent:YES];
//        [self.view addSubview:view];
//    
//        return;
    
    self.view.backgroundColor=[UIColor whiteColor];
    CTDrawView *view2 = [[CTDrawView alloc]initWithFrame:CGRectMake(5, 80, 365, 1000)];
    view2.backgroundColor= [UIColor grayColor];
    view2.delegate=self;
    
    FrameParserConfig *config2 = [FrameParserConfig defaultConfigWithContentSize:view2.bounds.size];
    config2.autoAdjustHeight = 1;
    config2.imageShowType=returnCenter;
    config2.integrate=0;
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


-(void)touchView:(UIView *)view imageName:(NSString *)source contentSources:(NSArray *)sources{
    NSLog(@"%@,%@",source,sources);
    //    UIImageView * one = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    //    [self.view addSubview:one];
    //    [HImageBox getImageWithSource:source option:^(UIImage *img, BOOL isFirst) {
    //        [one setImage:img];
    //    }];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [one removeFromSuperview];
    //    });
}
//-(void)touchView:(UIView *)view player:(id<CustomPlayerDelegate>)play videoSource:(NSString *)source{
//    
//}
-(NSArray *)getContent{
    
    NSArray *contentArr = @[
                            @{
                                @"content":@"A  @爱上无名氏 :x::x::o::o: SB",
                                @"type":@"link",
                                @"url":@"http://www.baidu.com",
                                @"size":@"12",
                                @"color":@"red",
                                @"underColor":@"black",
                                @"name":@"Futura"
                                },
                            @{
                                @"content":@"",
                                @"type":@"image",
                                @"src":@"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg",
                                @"width":@"200",
                                @"height":@"120",
                                @"isReturn":@"1",
                                @"isSingleLine":@"1"
                                },
                            @{
                                @"content" : @":+1:sz是计算文本不换行状态下单行的尺寸，linesSz是计算文本在换行状态下的尺寸。通过在算出位置添加一个较大的看不见的按钮监听点击事件，大部分情况 ",
                                @"type":@"text",
                                @"color":@"blue",
                                @"size":@"11",
                                @"name":@"Futura",

                                }
                            ,
                            @{
                                @"type":@"video",
                                @"src":[[NSBundle mainBundle]URLForResource:@"video.mp4" withExtension:nil].absoluteString,
                                @"width":@"260",
                                @"height":@"120",
                                @"isCenter":@"0",
                                @"isSingleLine":@"NO"
                                }
                            ,
@{
@"content" : @":+1:sz是计算文本不换行状态下单行的尺寸，linesSz是计算文本在换行状态下的尺寸。通过在算出位置添加一个较大的看不见的按钮监听点击事件，大部分情况 ",
@"type":@"text",
@"color":@"blue",
@"size":@"11",
@"name":@"Futura",

},
@{
@"content":@"    ",
@"type":@"video",
@"src":@"http://www.twsjwz.com/1-3-16/asia/0e2806cc3818b3bd8deaa1260.mp4",
@"width":@"260",
@"height":@"120"
}
,
@{
@"content":@"提供的网络视频链接可能失效",
@"type":@"text",
@"color":@"blue",
@"size":@"12",
@"name":@"Futura"
}


                            ];
    return contentArr;
}
-(void)dealloc{
    NSLog(@"控制器dealloc");
}

@end

/*

*/
