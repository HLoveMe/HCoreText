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


@implementation Message
-(NSString *)showContent{
    if (_showContent) {
        return  _showContent;
    }
    if (self.parserHandle) {
        _showContent = self.parserHandle(self.type,self.content).copy;
    }else{
        _showContent = self.showBack(self.type,self.content).copy;
    }
    
    return _showContent;
}

@end
@implementation TextMessage
- (instancetype)init{
    self = [super init];
    if (self) {
        self.paragraConfig = [[paragraphConfig alloc]init];
    }
    return self;
}
-(NSDictionary *)partAttribute:(FrameParserConfig *)defaultConfig{
    NSAssert(self.keyValues, @"在解析之后再获取该属性参数");
    FontConfig *config = [[FontConfig alloc]initWithFontConfig:defaultConfig.fontCig];
    [self.keyValues enumerateObjectsUsingBlock:^(keyValue * _Nonnull keyValue, NSUInteger idx, BOOL * _Nonnull stop) {
        id value;
        if (keyValue.valueHandle) {
            value = keyValue.valueHandle(keyValue.keyword,keyValue.value,keyValue.clazz);
        }else{
            value = keyValue.valueBack(keyValue.keyword,keyValue.value,keyValue.clazz);
        }
        [config setValue:value forKeyPath:keyValue.keyPath];
    }];
    _fontCig = config;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[(id)kCTFontAttributeName] = (__bridge id _Nullable)((__bridge CTFontRef)self.fontCig.font);
    dic[(id)kCTForegroundColorAttributeName] =  (__bridge id _Nullable)(self.fontCig.textColor.CGColor);
    dic[(id)kCTParagraphStyleAttributeName]= (id)self.paragraConfig.style;
    return dic;
}

@end

@implementation ImageMessage
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
-(NSDictionary *)partAttribute{
    if (self.src==nil||self.src.length==0) { NSAssert(false, @"图片源解析错误");}
    CTRunDelegateCallbacks callBack;
    callBack.version = kCTRunDelegateVersion1;
    callBack.dealloc = dealloc;
    callBack.getAscent = getAscent;
    callBack.getDescent = getDescent;
    callBack.getWidth = getWidth;
    CTRunDelegateRef ref = CTRunDelegateCreate(&callBack, (__bridge void * _Nullable)(self));
    return @{(id)kCTRunDelegateAttributeName:(__bridge id)ref};
}

@end