//
//  FrameParserConfig.h
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  用于配置一段文本的渲染时的参数
 *  对于整个文本内容，包含多片段，每个片段都有属于自己的FrameParserConfig对象
 */
@interface FrameParserConfig : NSObject
/**
 *  文字大小 default 14.0f
 */
@property(nonatomic,assign)CGFloat fontSize;
/**
 *  系统名字 default:  .SFUIText-Regular
 */
@property(nonatomic,copy)NSString *fontName;

/**
 *  default系统默认字体
 */
@property(nonatomic,strong)UIFont *font;
/**
 *  行间距  default 3
 */
@property(nonatomic,assign)CGFloat LineSpace;
/**
 *  文本颜色 blackColor
 */
@property(nonatomic,strong)UIColor *textColor;
/**
 *  当文本 实际占用size不等于给定的Size 是否调整 NO
 */
@property(nonatomic,assign)BOOL autoAdjustHeight;
/**
 *  第一行文字预留空隙 2*fontSize
 */
@property(nonatomic,assign)CGFloat firstLineIndent;
/**
 *  得到该对象的副本
 *
 *  @return
 */
-(instancetype)copy;
/**
 *  默认配置
 *
 *  @param contentRect 完整内容的rect
 *
 *  @return
 */
+(instancetype)defaultConfig;
@end
