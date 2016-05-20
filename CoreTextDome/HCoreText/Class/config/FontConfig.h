//
//  FontConfig.h
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
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
 *  文本颜色 blackColor
 */
@property(nonatomic,strong)UIColor *textColor;
/**
 *  下划线:None(0X00) Single(0X01) Thick(0X02) Double(0X09) 指定 underLineStyle
 */
//Solid(0X0000) Dot(0x0100) Dash(0X200) DashDot(0X300) DashDotDot(0x0400)
@property(nonatomic,copy)NSString *underLine;
@property(nonatomic,assign,readonly)int underLineStyle;
/**
 *  下划线颜色
 */
@property(nonatomic,strong)UIColor *underColor;
/**
 *  背景颜色 default:白色
 */
@property(nonatomic,strong)UIColor *backColor;

/**
 *  使用FontConfig 创建新的FontConfig
 *
 *  @param font
 *
 *  @return 
 */
+(instancetype)fontWithFontConfig:(FontConfig *)font;

-(NSMutableDictionary *)fonttAttributes;
@end
