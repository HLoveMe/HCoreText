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
        self.underLine = @"None";
        self.underColor = self.textColor;
        self.backColor = [UIColor whiteColor];
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
-(void)setTextColor:(UIColor *)textColor{
    _textColor =textColor;
    _underColor = textColor;
}
-(void)setUnderLine:(NSString *)underLine{
    _underLine=underLine;
    //    None(0X00) Single(0X01) Thick(0X02) Double(0X09)
//    Solid(0X0000) Dot(0x0100) Dash(0X200) DashDot(0X300) DashDotDot(0x0400)
    if ([@"None" containsString:underLine]) {
        _underLineStyle = 0x00;
    }else if([@"Single" containsString:underLine]){
        _underLineStyle = 0x01;
    }else
     if([@"Thick" containsString:underLine]){
        _underLineStyle = 0x02;
    }else
     if([@"Double" containsString:underLine]){
        _underLineStyle = 0x09;
    }
 
}
+(instancetype)fontWithFontConfig:(FontConfig *)font{
    FontConfig *config = [[FontConfig alloc]init];
    unsigned int  count;
    objc_property_t *pros = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        NSString *name =[NSString stringWithUTF8String:property_getName(pros[i])];
        id  value = [font valueForKey:name];
        if (value) {
            [config setValue:value forKey:name];
        }
    }
    return config;
}
-(NSMutableDictionary *)fonttAttributes{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[(id)kCTFontAttributeName] = (__bridge id _Nullable)((__bridge CTFontRef)self.font);
    dic[(id)kCTForegroundColorAttributeName] =  (__bridge id _Nullable)(self.textColor.CGColor);
    dic[(id)kCTUnderlineColorAttributeName] =(__bridge id _Nullable)(self.underColor.CGColor);
    dic[(id)kCTUnderlineStyleAttributeName]=(__bridge id _Nullable)((__bridge CFNumberRef)@(self.underLineStyle));
    
    return dic;
}

@end
