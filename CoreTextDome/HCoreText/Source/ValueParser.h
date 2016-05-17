//
//  ValueParser.h
//  CoreTextDome
//
//  Created by space on 16/4/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//
#ifndef ValueParser_h
#define ValueParser_h
@class Message;
/**
 *  enum 来标记该段内容是形式
 *   TextType 文本内容
 *   LinkType  
 *   ImageType 图片内容
 */
typedef enum{
    TextType = 1,
    LinkType,
    ImageType
}SourceType;
/**
 *  用于回调 把整个文本 按照开发者的需求分割为 几个片段（将要显示的内容 和 该内容的配置信息 的结合）
 *
 *  @param parserContentSplitBack
 *
 *  @return 片段集合
 */
typedef NSMutableArray<NSString *>* (*parserContentSplitBack)(NSString *wholeContent);

/**
 * 从片段中得到将要展示的内容
 *
 *  @param parserShowContentBack
 *
 *  @return
 */
typedef NSString *(*parserShowContentBack)(SourceType type,NSString *partString);
/**
 *  得到该部分需要解析的关键字
 *
 *  @param keywordsParser
 *
 *  @return 该部分需要解析的关键字
 */
typedef NSArray<NSString *>*(*parserKeywords)(NSString *partText);
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
typedef id (*parserValueCallBack)(NSString * key,NSString *value,Class clazz);
/**
 *  给定某个片段的内容 创建属于该片段的 TextMessage对象
 *
 *  @param parserSectionCallBack
 *
 *  @return
 */
typedef Message *(*parserSectionCallBack)(NSString *partString,NSArray *keywords,parserValueCallBack valueBack);

typedef struct {
    parserContentSplitBack contentBack;
    parserSectionCallBack sectionBack;
    parserShowContentBack showContentBack;
    parserKeywords    keywordsBack;
    parserValueCallBack valueBack;
}parserCallBacks;
#endif
