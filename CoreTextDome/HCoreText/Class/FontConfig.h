//
//  FontConfig.h
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface FontConfig : NSObject
/**
 *  文字大小 default 12.0f
 */
@property(nonatomic,assign)CGFloat fontSize;
/**
 *  系统名字 default:  Helvetica
 */
@property(nonatomic,copy)NSString *fontName;
/**
 *  默认字体
 *  default 系统默认字体
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
 *  使用FontConfig 创建新的FontConfig
 *
 *  @param font
 *
 *  @return 
 */
-(instancetype)initWithFontConfig:(FontConfig *)font;
@end
