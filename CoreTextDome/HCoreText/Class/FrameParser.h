//
//  FrameParser2.h
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ValueParser.h"
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
 *  @XXOO<font name=\"Futura\" size=\"20\" color=\"blue\" >
 *  <image src=\"%@\" width=\"200\" height=\"120\">
 *   Love <font name=\"Futura\" size=\"12\" color=\"red\">
 *   you <font name=\"Futura\" size=\"16\" color=\"red\">
 *
 *  Note:具体实现请参照  FrameParserObject
 *  @param content  解析的内容
 *  @param defaultC 默认配置
 *
 *  @return
 */
+(CoreTextData *)parserContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC;
@end

@interface FrameParser (CallBack)
/**
 *  根据给定的 parserCallBacks来解析一段文本
 *  Note: 请参考 parserWithPropertyContent:contentSize:defaultConfig:
 *  @param content  解析的文本
 *  @param defaultC 默认整体的配置信息
 *  @param size     content 将要显示的视图的size
 *  @param calls
 *  @return
 */
+(CoreTextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC  callBack:(parserCallBacks)calls;
/**
 *  特殊的解析文本 C 函数  
 * 这个方法内容调用的是 parserContent:defaultConfig:callBack:
 *  使用的解析器函数在source/specialDeal.h文件中完整的给出 如果你的文本和这个格式一致
 *  只需要修改部分即可
 *
 * I<font name=\"XX\" size=\"20\" color=\"blue\"> Love<font name=\"XX\" size=\"12\" color=\"red\"><image src="" withd="" height="">you<font name=\"\" size=\"25\">
 *   被分解成4部分
 * > I<font name=\"XX\" size=\"20\" color=\"blue\">
 * > Love <font name=\"XX\" size=\"12\" color=\"red\">
 * > <image src="" withd="" height="">
 * > you<font name=\"\" size=\"25\">
 *  @param content       要解析的文本
 *  @param size          内容所在的View 的 Size
 *  @param defaultConfig 提供默认的配置参数
 *  @return
 */
+(CoreTextData *)parserWithPropertyContent2:(NSString *)content defaultConfig:(FrameParserConfig *)defaultConfig;
@end
