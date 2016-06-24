//
//  partConfig.m
//  CoreTextDome
//
//  Created by space on 16/4/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "partMessage.h"
#import "FontConfig.h"
#import "FrameParserConfig.h"
#import <objc/runtime.h>
@implementation keyValue
-(NSString *)value{
    if (_value){
        return _value;
    }else{
        [self.expression enumerateObjectsUsingBlock:^(NSRegularExpression * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSTextCheckingResult *result = [obj firstMatchInString:self.content options:0 range:NSMakeRange(0, self.content.length)];
            if (result) {
               _value = [self.content substringWithRange:result.range];
                *stop=YES;
            }
        }];
        return _value;
    }
}
-(void)setKeyword:(NSString *)keyword{
    _keyword = [keyword copy];
    static NSDictionary *key_path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath_text" ofType:@"plist"];
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

@interface Message()

@end
@implementation Message
@end
@implementation TextMessage
- (instancetype)init{
    self = [super init];
    if (self) {
        self.paragraConfig = [[paragraphConfig alloc]init];
    }
    return self;
}
-(FontConfig *)parserKeyValues:(FontConfig *)defaultCfg{
    //解析参数值
    FontConfig *config = [FontConfig fontWithFontConfig:defaultCfg];
    [self.keyValues enumerateObjectsUsingBlock:^(keyValue * _Nonnull keyValue, NSUInteger idx, BOOL * _Nonnull stop) {
        id value;
        if (keyValue.valueHandle) {
            value = keyValue.valueHandle(keyValue.keyword,keyValue.value,keyValue.clazz);
        }
        [config setValue:value forKeyPath:keyValue.keyPath];
    }];
    return config;
}
-(NSMutableDictionary *)partAttribute:(FontConfig *)defaultConfig{
    NSAssert(self.keyValues, @"在解析之后再获取该属性参数");
    _fontCig = [self parserKeyValues:defaultConfig];
    NSMutableDictionary *dic = [self.fontCig fonttAttributes];
    dic[(id)kCTParagraphStyleAttributeName]= (id)self.paragraConfig.style;
    return dic;
}
@end

@implementation TextLinkMessage
-(FontConfig *)parserKeyValues:(FontConfig *)defaultCfg{
    //解析参数值
    FontConfig *config = [FontConfig fontWithFontConfig:defaultCfg];
    [self.keyValues enumerateObjectsUsingBlock:^(keyValue * _Nonnull keyValue, NSUInteger idx, BOOL * _Nonnull stop) {
        id value;
        if (keyValue.valueHandle) {
            value = keyValue.valueHandle(keyValue.keyword,keyValue.value,keyValue.clazz);
        }
        if ([self isSelfProperty:keyValue.keyPath]) {
            [self setValue:keyValue.value forKey:keyValue.keyPath];
        }else{
            [config setValue:value forKeyPath:keyValue.keyPath];
        }
        
    }];
    return config;
}

-(BOOL)isSelfProperty:(NSString*)proName{
    static dispatch_once_t onceToken;
    static  NSString *proNameStr;
    dispatch_once(&onceToken, ^{
        NSMutableArray *proNames = [NSMutableArray array];
        unsigned int  count;
        objc_property_t *pros = class_copyPropertyList([self class], &count);
        for (int i=0; i<count; i++) {
            NSString *name =[NSString stringWithUTF8String:property_getName(pros[i])];
            [proNames addObject:name];
        }
        proNameStr = [proNames componentsJoinedByString:@"|"];
    });
    return [proNameStr containsString:proName];
}

@end

@implementation ImageMessage
-(instancetype)init{
    if (self=[super init]) {
        self.isReturn=NO;
        self.isCenter=NO;
    }
    return self;
}
void dealloc (void * refCon ){
    CFRelease(refCon);
}
/**
 *高度
 */
CGFloat getAscent(void * refCon ){
    ImageMessage *msg = (__bridge ImageMessage *)(refCon);
    return msg.height;
}
CGFloat getDescent(void * refCon ){
    return  0;
}
CGFloat getWidth(void * refCon ){
    ImageMessage *msg = (__bridge ImageMessage *)(refCon);
    return msg.width;
}

-(NSMutableDictionary *)partAttribute{
    if (self.src==nil||self.src.length==0) { NSAssert(false, @"源解析错误");}
    CTRunDelegateCallbacks callBack;
    callBack.version = kCTRunDelegateVersion1;
    callBack.dealloc = dealloc;
    callBack.getAscent = getAscent;
    callBack.getDescent = getDescent;
    callBack.getWidth = getWidth;
    CTRunDelegateRef ref = CTRunDelegateCreate(&callBack, (__bridge void * _Nullable)(self));
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary: @{(id)kCTRunDelegateAttributeName:(__bridge id)ref}];
    
    
    return dic;
}
@end

@implementation VideoMessage


@end