//
//  FontConfig.m
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FontConfig.h"
#import <objc/runtime.h>
@implementation FontConfig
-(instancetype)init{
    if(self=[super init]){
        self.fontSize = 12.f;
        self.fontName = @"Helvetica";
        self.textColor = [UIColor blackColor];
    }
    return self;
}
-(void)setFontName:(NSString *)fontName{
    _fontName = fontName;
    _font = [UIFont fontWithName:fontName size:self.fontSize];
}
-(void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    _font = [UIFont fontWithDescriptor:[self.font fontDescriptor] size:fontSize];
}
-(instancetype)initWithFontConfig:(FontConfig *)font{
    FontConfig *config = [[FontConfig alloc]init];
    unsigned int  count;
    objc_property_t *pros = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        NSString *name =[NSString stringWithUTF8String:property_getName(pros[i])];
        id  value = [self valueForKey:name];
        if (value) {
            [config setValue:value forKey:name];
        }
    }
    return config;
}
@end
