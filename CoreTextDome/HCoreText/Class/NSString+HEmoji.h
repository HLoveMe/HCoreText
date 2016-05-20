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
 *     >修改 NSString+HEmoji.m的 21行 正则表达式
 *  或者你重写该NSString+HEmoji.m实现
 */
@interface NSString (HEmoji)
- (NSString *)emojizedString;
+ (NSString *)emojizedStringWithString:(NSString *)text;
+ (NSDictionary *)emojiAliases;
@end
