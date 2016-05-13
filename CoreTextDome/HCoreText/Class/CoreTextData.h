//
//  CoreTextData.h
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@class Message;
@class FrameParserConfig;
/**
 *  解析器解析文本后产生的数据类
 */
@interface CoreTextData : NSObject
/**
 *
 */
@property(nonatomic,strong)FrameParserConfig *parserCfg;
/**
 *  解析出来的文本
 */
@property(nonatomic,copy)NSAttributedString *contentString;

/**
 *  在渲染时 是否自动调节 视图的高度（该值是通过FrameParserConfig获取的）
 */
@property(nonatomic,readonly)BOOL isAutoAdjustHeight;
/**
 *  通过配置信息 解析出来文本所占空间的实际高度
 */
@property(nonatomic,assign)CGFloat realContentHeight;
/**
 *  文本渲染的主体
 */
@property(nonatomic,assign)CTFrameRef frameRef;
/**
 *  本文本的所有Message对象
 */
@property(nonatomic,strong)NSMutableArray<Message *> *msgArray;

@end
