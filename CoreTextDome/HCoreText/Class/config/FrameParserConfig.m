//
//  FrameParserConfig.m
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParserConfig.h"
#import "paragraphConfig.h"
#import <objc/runtime.h>
@interface FrameParserConfig()
@property(nonatomic,strong)paragraphConfig *parCig;
@end
@implementation FrameParserConfig
- (instancetype)init{
    if (self=[super init]) {
        self.autoAdjustHeight = NO;
        self.parCig = [[paragraphConfig alloc]init];
        self.fontCig = [[FontConfig alloc]init];
        self.pattern = @"(:[a-z0-9-+_]+:)";
        self.imageShowType=defaultReturn;
        self.videoShowType=returnCenter;
//        self.videoClazz=NSClassFromString(@"HVideoPlayView");
    }
    return self;
}
-(void)setPattern:(NSString *)pattern{
    _pattern =[pattern copy];
    NSUserDefaults * defalut = [NSUserDefaults standardUserDefaults];
    [defalut setObject:pattern forKey:@"H_pattern"];
    [defalut synchronize];
}
-(NSDictionary *)defaultAttribute{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[(id)kCTFontAttributeName] = (__bridge id _Nullable)((__bridge CTFontRef)self.fontCig.font);
    dic[(id)kCTForegroundColorAttributeName] =  (__bridge id _Nullable)(self.fontCig.textColor.CGColor);
    dic[(id)kCTParagraphStyleAttributeName]= (id)self.parCig.style;
    return dic;
}
+(instancetype)defaultConfigWithContentSize:(CGSize)size{
    FrameParserConfig *config = [[FrameParserConfig alloc]init];
    config.contentSize = size;
    return config;
}
-(instancetype)initParperConfigWithContentSize:(CGSize)size paragraph:(paragraphConfig *)cfg{
    if (self = [super init]) {
        self.contentSize=size;
        self.autoAdjustHeight= NO;
        self.parCig = cfg;
        self.fontCig = [[FontConfig alloc]init];
    }
    return self;
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

