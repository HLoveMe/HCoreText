//
//  FrameParser+dict.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/18.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParser.h"
@interface FrameParser (dict)
/**
 *  对解析的文本一个实例
 *  @param content  解析的文本内容
 *  @param defaultC
 *
 *  @return
 */
+(CoreTextData *)parserWithSource:(NSArray<NSDictionary<NSString * ,NSString *>*> *)content defaultCfg:(FrameParserConfig *)defaultC;
@end

/**
 NSArray *contentArr = @[
                          @{
                            @"content":@"@爱上无名氏",
                            @"type":@"link",
                            @"url":@"http://www.baidu.com",
                            @"size":@"18",
                            @"color":@"red"
                          },
                        @{
                            @"content":@" ",
                            @"type":@"image",
                            @"src":@"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg",
                            @"width":@"200",
                            @"height":@"120"
                        },
                        @{
                            @"content":@"I love you 无名氏个大傻逼",
                            @"type":@"text",
                            @"color":@"blue",
                            @"size":@"18",
                            @"name":@"Futura"
                        }
                    ];

 */