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
@class FrameParserConfig;
@class CoreTextData;
/**
 *  用于parser 和开发者的交互
 *
 *  @param argumentString 该段文本的形式
 *
 *  @param argumentString 返回当前解析的文字
 *
 *  @return 当前文本需要解析的关键字集合
 */
typedef NSArray *(^keywordsBlock)(SourceType type,NSString * argumentString);
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
 *  最基础的文字解析
 *  使用这个解析器方法   你需要完整的提供 1：整个文本分块操作 2：需要解析的关键字 3：怎么通过关键字 从文本中解析到对应的值
 *  Note:参考 parserWithPropertyContent:defaultConfig:
 *  @param content    需要解析的内容
 *  @param defaultC   默认的文本配置
 *  @param size       整个文本渲染在默认视图 size就是该视图的
 *  @param handle     提供NSRegularExpression以便解析器 解析整个文本 按照样式 分为不同的部分
 *  @param parthandle 传递某个片段 解析者提供Message对象
 *
 *  @return
 */
+(CoreTextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC sectionHandle:(NSRegularExpression *)handle partContentDeal:(Message *(^)(NSString * onepart))parthandle;
/**
 * 特殊的解析文本  Block
 * I<font name=\"XX\" size=\"20\" color=\"blue\"> Love<font name=\"XX\" size=\"12\" color=\"red\"><image src="" withd="" height="">you<font name=\"\" size=\"25\">
 *   被分解成4部分
 * > I<font name=\"XX\" size=\"20\" color=\"blue\">
 * > Love <font name=\"XX\" size=\"12\" color=\"red\">
 * > <image src="" withd="" height="">
 * > you<font name=\"\" size=\"25\">
 *  @param content       要解析的文本
 *  @param size          内容所在的View 的 Size
 *  @param defaultConfig 提供默认的配置参数
 *  @param keywords      每次解析 都会调用  返回解析的关键字集合
 *  @return
 */
+(CoreTextData *)parserWithPropertyContent:(NSString *)content  defaultConfig:(FrameParserConfig *)defaultConfig;
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
