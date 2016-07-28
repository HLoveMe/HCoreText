//
//  NSString+HEmoji.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "NSString+HEmoji.h"
@implementation NSString (HEmoji)
- (NSString *)emojizedStringWithCurrent:(TextMessage *)textmsg{
     return [NSString emojizedStringWithString:self current:textmsg];
}
static NSRegularExpression *regex = nil;
static NSArray<NSTextCheckingResult *> *result = nil;
//判断是否包含Emoji表情
+(BOOL)hasEmoji:(NSString *)content{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //匹配emoji表情字符串
        NSUserDefaults * defalut = [NSUserDefaults standardUserDefaults];
        NSString *pattern = [defalut valueForKey:@"H_pattern"];
        regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    result = [regex matchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, content.length)];
    return result.count>=1;
}

+ (NSString *)emojizedStringWithString:(NSString *)text current:(TextMessage *)textmsg{
    if (![NSString hasEmoji:text]) {
        return text;
    }
    //根据需求替换emoji表情
    __block NSString *resultText = text;
    NSMutableArray *array = [NSMutableArray array];
    __block int temp=0;
    [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                NSString *unicode = self.emojiAliases[code];
                
                NSRange tempRan = NSMakeRange(range.location-temp, unicode.length);
                temp +=code.length-unicode.length;
                if (unicode) {
                    resultText = [resultText stringByReplacingOccurrencesOfString:code withString:unicode];
                }
                [array addObject:[NSValue valueWithRange:tempRan]];
            }
        }
    }];
    textmsg.emojiRange=array;
    return resultText;
}

+ (NSDictionary *)emojiAliases {
    static NSDictionary *_emojiAliases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiAliases = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"emoji.plist" ofType:nil]];
    });
    return _emojiAliases;
}

@end
