//
//  paragraphConfig.h
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
/**
 *  NSParagraphStyle
 */
@interface paragraphConfig : NSObject
/**
 *  kCTParagraphStyleSpecifierAlignment Defalut:kCTTextAlignmentNatural
 */
@property(nonatomic,assign)CTTextAlignment alignment;
/**
 *  kCTParagraphStyleSpecifierFirstLineHeadIndent default:0
 *  第一行头部空格
 */
@property(nonatomic,assign)CGFloat firstLineHeadIndent;
/**
 *  kCTParagraphStyleSpecifierHeadIndent default:0.0
 *  顶部间隔
 */
@property(nonatomic,assign)CGFloat headIndent;
/**
 *  kCTParagraphStyleSpecifierTailIndent default:0.0
 *  底部间隔
 */
@property(nonatomic,assign)CGFloat tailIndent;
/**
 *  kCTParagraphStyleSpecifierLineBreakMode default:kCTLineBreakByWordWrapping
 *  换行模式： 单词换行
 */
@property(nonatomic,assign)CTLineBreakMode breakMode;
/**
 *   kCTParagraphStyleSpecifierMaximumLineSpacing  default:some large number
 *   kCTParagraphStyleSpecifierMinimumLineSpacing  default:0.0
 *   kCTParagraphStyleSpecifierLineSpacingAdjustment default:0.0
 *   共同调节行间距
 */
@property(nonatomic,assign)CGFloat MaxLineSpace;
@property(nonatomic,assign)CGFloat MinLineSpace;
@property(nonatomic,assign)CGFloat lineSpace;
/**
 *  kCTParagraphStyleSpecifierBaseWritingDirection default:kCTWritingDirectionNatural
 *  渲染方向
 */
@property(nonatomic,assign)CTWritingDirection direction;
/**
 *  在设置属性后得到配置属性
 */
@property(nonatomic,assign,readonly)CTParagraphStyleRef  style;
/**
 *  @return 返回系统默认段落配置
 */
+(CTParagraphStyleRef)defaultConfig;
@end
