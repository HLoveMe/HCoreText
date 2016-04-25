//
//  FrameParserConfig.m
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParserConfig.h"
#import <objc/runtime.h>
@implementation FrameParserConfig
-(instancetype)init{
    if(self=[super init]){
        self.fontSize = 14.f;
        _font = [UIFont systemFontOfSize:self.fontSize];
        self.fontName = @".SFUIText-Regular";
        self.LineSpace = 3.0f;
        self.textColor = [UIColor blackColor];
        self.autoAdjustHeight = NO;
        self.firstLineIndent=2*self.fontSize;
//        self.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
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

+(instancetype)defaultConfig{
    FrameParserConfig *config = [[FrameParserConfig alloc]init];
    return config;
}
-(instancetype)copy{
    FrameParserConfig *config = [[FrameParserConfig alloc]init];
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

