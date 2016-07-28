//
//  partConfig.h
//  CoreTextDome
//
//  Created by space on 16/4/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "paragraphConfig.h"
#import "ParserType.h"
@class FontConfig;
@class FrameParserConfig;

/**
 *  这个方法是根据片段 partConfig对象
 *  各个配置关键字,关键字对于的值,值对应片段的FrameParserConfig 属性的Class
 *  example
 *      <text color="red">
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
@property(nonatomic,copy)NSString *value;
/**
 *  配置参数对于的值,值对应FontConfig的属性名
 */
@property(nonatomic,copy,readonly)NSString *keyPath;
/**
 *  对应FrameParserConfig属性的值 的Class keyword_keyPath_text/image.plist
 */
@property(nonatomic,assign,readonly)Class clazz;
/**
 *  如果是通过创建 struct parserCallBacks 来解析文本  该属性 不需要赋值
 */
@property(nonatomic,copy)parserValueHandle valueHandle;
/**
 *  解析的正则表达式对象 通过该对象解析得到 关键字的值 
 */
@property(nonatomic,strong)NSArray<NSRegularExpression*> *expression;
@end


//*************************************************************************************
@interface Message:NSObject

/**
 *  该段内容的形式  text image  
 *  Note:在从创建时赋值
 */
@property(nonatomic,assign)SourceType type;
/**
 *  该文本在整体文本的Range 
 *  Note:在解析之后就会赋值
 */
@property(nonatomic,assign)NSRange contentRange;
/**
 *将要显示出来的文本
 */
//@property(nonatomic,copy)NSString *showContent;
/**
 *  该part段落文本
 *  Note:解析之后就会有值
 */
@property(nonatomic,strong)NSMutableAttributedString *attSring;
@end

/**
 *  这是一个文本分块信息类
 */
@interface TextMessage : Message
/**
 * 文本字体配置 
 * 有默认值
 */
@property(nonatomic,strong,readonly)FontConfig *fontCig;
/**
 *  该段落所有的（关键字-值）对象  
 *  Note:在从创建时赋值
 */
@property(nonatomic,strong)NSArray<keyValue *> *keyValues;
/**
 *  该文本中 Emoji表情占据的range
 */
@property(nonatomic,strong)NSMutableArray *emojiRange;
/**
 *  段落配置信息   
 *   Note:在从创建时赋值  有默认值
 */
@property(nonatomic,strong)paragraphConfig * paragraConfig;
/**
 * 给定默认的全局配置  和FontConfig 得到文本属性字典
 */
-(NSMutableDictionary *)partAttribute:(FontConfig *)defaultConfig;
@end


@interface TextLinkMessage : TextMessage
/**
 *  表示文本之后的真实URL 关键字:url
 */
@property(nonatomic,copy)NSString *URLSrc;

@end


@interface ImageMessage : Message
/**
 *  当前图片是否换行显示 YES
 */
@property(nonatomic,assign)BOOL isReturn;
/**
 *  当前图片是否居中显示 YES
 */
@property(nonatomic,assign)BOOL isCenter;
/**
 *  是否为单行显示  default = 1 
 *  isSingleLine  优先级 大于  isCenter
 */
@property(nonatomic,assign)BOOL isSingleLine;
/**
 *  宽
 * Note:在从创建时赋值
 */
@property(nonatomic,assign)CGFloat width;
/**
 *  高
 * Note:在从创建时赋值
 */
@property(nonatomic,assign)CGFloat height;
/**
 *  源
 * Note:在从创建时赋值
 */
@property(nonatomic,copy)NSString *src;
/**
 *  在UIView中显示的位置坐标
 *  在绘画完成后自动赋值
 */
@property(nonatomic,assign)CGRect rect;
/**
 *
 *
 *  @return
 */
-(NSMutableDictionary *)partAttribute;
@end


@interface VideoMessage : ImageMessage
/**
 *  标示是否已经渲染 ，刷新将不会再次渲染
 */
@property(nonatomic,assign)BOOL hasShow;
@end
