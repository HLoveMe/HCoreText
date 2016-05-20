//
//  NSString+HEmoji.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

//由于不同的业务需求对emoji显示的方式不一样
/**
 *  该实例是 :+1: 对应 \U0001F44D
 *  有些情况情况 [emoji]赞[/emoji] 对应 \U0001F44D
 *  或者其他
 *     >替换emoji.plist
 *     > 修改FrameParserConfig匹配规则
 */
@interface NSString (HEmoji)
/**
 *  替换Emoji
 *
 *  @return
 */
- (NSString *)emojizedString;
/**
 *  替换Emoji
 *
 *  @param text
 *
 *  @return
 */
+ (NSString *)emojizedStringWithString:(NSString *)text;
/**
 *  得到所有emoji  emoji.plist
 *
 *  @return
 */
+ (NSDictionary *)emojiAliases;
@end
