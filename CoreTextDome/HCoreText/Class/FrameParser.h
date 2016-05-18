//
//  FrameParser2.h
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "partMessage.h"
#import "FrameParserDelegate.h"
@class FrameParserConfig;
@class CoreTextData;

@interface FrameParser : NSObject
/**
 *  单纯的文字
 *
 *  @param content 文本
 *  @param config  配置
 *
 *  @return
 */
+(CoreTextData *)parserContent:(NSString *)content withConfig:(FrameParserConfig *)config;
/**
 *  最基础的解析
 *
 *  @param content  解析的文本 带有文本配置
 *  @param defaultC 全局的配置
 *  @param delegate 实现了FrameParserDelegate代理的对象
 *
 *  @return
 */
+(CoreTextData *)parserContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC parserDelegate:(id<FrameParserDelegate>)delegate;
/**
 *  提供一个解析实例
 *
 *   @XXOO<text name=\"Futura\" size=\"20\" color=\"blue\" >
 *   <image src=\"%@\" width=\"200\" height=\"120\">
 *   Love <text name=\"Futura\" size=\"12\" color=\"red\">
 *   you <text name=\"Futura\" size=\"16\" color=\"red\">
 *   @爱上无名氏<link url="",size=...>
 *  Note:具体实现请参照  FrameParserObject
 *  @param content  解析的内容
 *  @param defaultC 默认配置
 *
 *  @return
 */
+(CoreTextData *)parserWithPropertyContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC;
@end








