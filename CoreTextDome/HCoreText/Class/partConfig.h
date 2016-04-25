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
 *  对应FrameParserConfig属性的值 的Class keyword_keyPath.plist
 */
@property(nonatomic,assign,readonly)Class clazz;
/**
 *  根据keyword_keyPath配置文件的对应值 把解析的结果 转化为FrameParserConfig属性的值
 *  如果是通过创建 struct parserCallBacks 来解析文本  该属性 不需要赋值
 */
@property(nonatomic,copy)parserValueHandle valueHandle;
/**
 *  解析的正则表达式对象 通过该对象解析得到 关键字的值
 */
@property(nonatomic,strong)NSRegularExpression *expression;
@end


//*************************************************************************************
 
/**
 *  这是一个分块配置类
 */
@interface partConfig : NSObject
/**
 *  该段内容的形式  text image
 */
@property(nonatomic,assign)SourceType type;
/**
 *  该段落所有的（关键字-值）对象
 */
@property(nonatomic,strong)NSArray<keyValue *> *keyValues;
/**
 *  该part段落文本
 */
@property(nonatomic,copy)NSString *content;
/**
 *  通过该回调函数 得到需要显示的具体文本
 */
@property(nonatomic,copy)parserContentHandle parserHandle;
@end
