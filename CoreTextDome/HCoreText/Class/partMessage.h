//
//  partConfig.h
//  CoreTextDome
//
//  Created by space on 16/4/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ValueParser.h"
#import "paragraphConfig.h"
@class FontConfig;
@class FrameParserConfig;
/**
 *  用于解析文字 (文字和配置参数)得到文字 I Love you <font name="">  得到 I Love you 文本
 *
 *  @param content (文字和配置参数)
 *  @param type 文本类型
 *  @return 文本
 */
typedef NSString *(^parserContentHandle)(SourceType type,NSString *content) ;
/**
 *  这个方法是根据片段 partConfig对象
 *  各个配置关键字,关键字对于的值,值对应片段的FrameParserConfig 属性的Class
 *  example
 *      <font color="red">
 *--->  ("color","red",UIColor)
 *  @param parserValueCallBack
 *
 *  @return 把关键字的值解析为clazz 具体的值
 */
typedef id(^parserValueHandle)(NSString * key,NSString *value,Class clazz);
/**
 *  这是针对关键字解析类
 */
@interface keyValue : NSObject
/**
 *  解析的文本内容
 */
@property(nonatomic,copy)NSString *content;
/**
 *  需要解析的关键字
 */
@property(nonatomic,copy)NSString *keyword;
/**
 *  关键字对应的值
 */
@property(nonatomic,copy,readonly)NSString *value;
/**
 *  配置参数对于的值,值对应FrameParserConfig的属性名
 */
@property(nonatomic,copy,readonly)NSString *keyPath;
/**
 *  对应FrameParserConfig属性的值 的Class keyword_keyPath_text.plist
 */
@property(nonatomic,assign,readonly)Class clazz;
/**
 *  根据keyword_keyPath_text配置文件的对应值 把解析的结果 转化为FontConfig属性的值
 *  如果是通过创建 struct parserCallBacks 来解析文本  该属性 不需要赋值
 *  valueHandle valueBack 按照解析方式 给其中一个赋值
 */
@property(nonatomic,copy)parserValueHandle valueHandle;
/**
 *  通过该函数得到 参数的具体值 （转化为FontConfig属性的值）
 *  valueHandle valueBack 按照解析方式 给其中一个赋值
 */
@property(nonatomic,assign)parserValueCallBack valueBack;
/**
 *  解析的正则表达式对象 通过该对象解析得到 关键字的值 
 */
@property(nonatomic,strong)NSRegularExpression *expression;
@end


//*************************************************************************************
@interface Message:NSObject
/**
 *  该段内容的形式  text image
 */
@property(nonatomic,assign)SourceType type;
/**
 *  该part段落文本
 */
@property(nonatomic,copy)NSString *content;
/**
 *  该文本在整体文本的Range
 */
@property(nonatomic,assign)NSRange contentRange;
/**
 *将要显示出来的文本
 */
@property(nonatomic,copy)NSString *showContent;
/**
 *  通过该回调函数 得到需要显示的具体文本
 */
@property(nonatomic,copy)parserContentHandle parserHandle;
/**
 *   通过该回调函数 得到需要显示的具体文本
 */
@property(nonatomic,assign)parserShowContentBack showBack;
@end

/**
 *  这是一个文本分块信息类
 */
@interface TextMessage : Message
/**
 * 文本字体配置
 */
@property(nonatomic,strong)FontConfig *fontCig;
/**
 *  该段落所有的（关键字-值）对象
 */
@property(nonatomic,strong)NSArray<keyValue *> *keyValues;

/**
 *  段落配置信息
 */
@property(nonatomic,strong)paragraphConfig *paragraConfig;
/**
 * 给定默认的全局配置  和FontConfig 得到文本属性字典
 */
-(NSDictionary *)partAttribute:(FrameParserConfig *)defaultConfig;
@end



@interface ImageMessage : Message

/**
 *  图片宽
 */
@property(nonatomic,assign)CGFloat width;
/**
 *  图片高
 */
@property(nonatomic,assign)CGFloat height;
/**
 *  图片源
 */
@property(nonatomic,copy)NSString *src;
/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)partAttribute;
@end

