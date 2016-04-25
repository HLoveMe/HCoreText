//
//  partConfig.m
//  CoreTextDome
//
//  Created by space on 16/4/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "partConfig.h"

@implementation partConfig

@end

@implementation keyValue
-(NSString *)value{
    NSTextCheckingResult *result = [self.expression firstMatchInString:self.content options:0 range:NSMakeRange(0, self.content.length)];
    return [self.content substringWithRange:result.range];
}
-(void)setKeyword:(NSString *)keyword{
    _keyword = [keyword copy];
    static NSDictionary *key_path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath" ofType:@"plist"];
        key_path = [NSDictionary dictionaryWithContentsOfFile:path];
    });
    NSString *keyPath = [key_path[self.keyword] firstObject];
    NSString *clazzStr =[key_path[self.keyword] lastObject];
    _keyPath = keyPath;
    _clazz = NSClassFromString(clazzStr);
    if(!_clazz){
        _clazz = [NSObject class];
    }
}
@end