//
//  FrameParserConfig.h
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FontConfig.h"

typedef enum{
    originality,   //原始格式 根据文字内容显示
    defaultReturn, // 内容会换行再显示 
    returnCenter   //换行 再居中显示
}lineFeedType;
@class paragraphConfig;
/**
 *  整体文本配置 在关键字解析失败会使用该对象提供的默认值
 */
@interface FrameParserConfig : NSObject
/**
 *  默认的字体配置
 */
@property(nonatomic,strong)FontConfig *fontCig;
/**
 *  行间距  default 0
 */
@property(nonatomic,assign)CGFloat LineSpace;
/**
 *  当文本 实际占用size不等于给定的Size 是否调整 NO
 */
@property(nonatomic,assign)BOOL autoAdjustHeight;
/**
 *  用于显示文本的视图的Size  default CGSizeZero
 *  Note:  
 */
@property(nonatomic,assign)CGSize contentSize;

/**
 *  提供默认的文字配置信息
 */
@property(nonatomic,strong,readonly)NSDictionary *defaultAttribute;
/**
 *  整体设置  图片显示的方法 如果在图片配置参数设置 isReturn isCenter 就会以配置为准
 *  default : defaultReturn
 */
@property(nonatomic,assign)lineFeedType imageShowType;

/**
 *  整体设置  图片显示的方法 如果在视频配置参数设置 isReturn isCenter 就会以配置为准
 *  default : returnCenter
 */
@property(nonatomic,assign)lineFeedType videoShowType;


////////////////////////Emoji.h//////////////////////////////////
/**
 *  用于解析emoji表情的匹配规则 default (:[a-z0-9-+_]+:)
 *  见 NSString+HEmoji.h

 */
@property(nonatomic,copy)NSString *pattern;
/**
 *  emoji 是否和文字大小一致  YES
 */
@property(nonatomic,assign)BOOL integrate;
/**
 *    [UIFont systemFontSize]
 */
@property(nonatomic,assign)CGFloat emojiZise;


/**
 *  得到该对象的副本
 *
 *  @return
 */
-(instancetype)copy;
/**
 *  默认配置
 *
 *  @param contentRect 完整内容的size
 *
 *  @return
 */
+(instancetype)defaultConfigWithContentSize:(CGSize)size;
/**
 *  使用段落配置来创建 FrameParserConfig
 *
 *  @param size 用于绘制的UIView的size
 *  @param cfg 段落配置
 *
 *  @return
 */
-(instancetype)initParperConfigWithContentSize:(CGSize)size paragraph:(paragraphConfig *)cfg;
@end
