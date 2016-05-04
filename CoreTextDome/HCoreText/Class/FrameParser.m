//
//  FrameParser2.m
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParser.h"
#import "FrameParserConfig.h"
#import "CoreTextData.h"
#import "partMessage.h"
#import "UIColor+Hex.h"
#import "ValueParser.h"
#import "specialDeal.h"
#import "paragraphConfig.h"
#import <objc/runtime.h>
@implementation FrameParser
+(CoreTextData *)parserContent:(NSString *)content withConfig:(FrameParserConfig *)config{
    NSDictionary *dic = [config defaultAttribute];
    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:content attributes:dic];
    TextMessage *textMsg = [[TextMessage alloc]init];
    textMsg.type = textType;
    textMsg.contentRange = NSMakeRange(0, content.length);
    textMsg.showContent = content;
    textMsg.content = content;
    CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    /**计算需要的空间*/
    CGSize size = config.contentSize;
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !config.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    CoreTextData *data = [[CoreTextData alloc]init];
    data.contentString = content;
    [data setValue:@(config.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.realContentHeight = contSize.height;
    data.frameRef = frameRef;
    data.msgArray = [NSMutableArray arrayWithObject:textMsg];
    CFRelease(setter);
    CFRelease(pathRef);
    return data;
}
/**
 *  最基础的解析
 *
 *  @param content    <#content description#>
 *  @param defaultC   <#defaultC description#>
 *  @param size       <#size description#>
 *  @param handle     <#handle description#>
 *  @param parthandle <#parthandle description#>
 *
 *  @return <#return value description#>
 */
+(CoreTextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC  sectionHandle:(NSRegularExpression *)handle partContentDeal:(Message *(^)(NSString * onepart))parthandle {
    CoreTextData *data =[[CoreTextData alloc]init];
    NSMutableArray *contentResult = [[handle matchesInString:content options:0 range:NSMakeRange(0, content.length)] mutableCopy];
    [contentResult removeLastObject];
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc]init];
    CGSize size  = defaultC.contentSize;
    [contentResult enumerateObjectsUsingBlock:^(NSTextCheckingResult  *result, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *obj = [content substringWithRange:result.range];
        NSAssert(parthandle, @"parthandle is nil error");
        Message *pConfig = parthandle(obj);
        [data.msgArray addObject:pConfig];
        /**得到显示的文本*/
        if (pConfig.type == textType) {
            TextMessage *TMsg= (TextMessage *)pConfig;
            NSString *oneCont = TMsg.parserHandle(pConfig.type,TMsg.content);
            NSDictionary *dic = [TMsg partAttribute:defaultC];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:oneCont attributes:dic];
            TMsg.contentRange = NSMakeRange(contentAtt.string.length, oneCont.length);
            [contentAtt appendAttributedString:oneAtt];
        }else{
            ImageMessage *imgMsg = (ImageMessage *)pConfig;
            NSString *placeStr = imgMsg.parserHandle(imgMsg.type,imgMsg.content);
            NSDictionary *dic = [imgMsg partAttribute];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:placeStr attributes:dic];
            imgMsg.contentRange = NSMakeRange(contentAtt.string.length, placeStr.length);
            [contentAtt appendAttributedString:oneAtt];
        }
        
    }];
    CTFramesetterRef setter =CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentAtt);
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !defaultC.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    data.contentString = contentAtt.string;
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.frameRef = frameRef;
    data.realContentHeight = contSize.height;
    CFRelease(setter);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return data;
}
+(NSMutableArray <keyValue *>*)parserKeyValuesWithKeys:(NSArray<NSString *>*)keys content:(NSString *)content{
     NSMutableArray *keyValues  =[NSMutableArray array];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        keyValue *keyV = [[keyValue alloc]init];
        keyV.keyword = obj;
        keyV.content = content;
        //3：怎么通过关键字 从文本中解析到对应的值
        NSString *Pattern = [NSString stringWithFormat:@"(?<=%@=\")\\w+",obj];
        NSRegularExpression *expression = [[NSRegularExpression alloc]initWithPattern:Pattern options:0 error:nil];
        keyV.expression=expression;
        //值解析
        keyV.valueHandle = ^id(NSString *key, NSString *value, __unsafe_unretained Class clazz) {
            id realValue ;
            if ([clazz isSubclassOfClass:[NSString class]]||[clazz isSubclassOfClass:[NSMutableString class]]) {
                realValue = value;
            }else if ([clazz isSubclassOfClass:[UIFont class]]){
                realValue = [UIFont fontWithName:value size:[UIFont systemFontSize]];
            }else if ([clazz isSubclassOfClass:[UIColor class]]){
                if ([value containsString:@"#"]||[value containsString:@"0X"]) {
                    realValue = [UIColor colorWithHexString:value];
                }else{
                    SEL aSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color",value]);
                    if ([UIColor respondsToSelector:aSel]) {
                        realValue = [UIColor performSelector:aSel];
                    }else{
                        realValue = [UIColor blackColor];
                    }
                }
            }else if ([clazz isSubclassOfClass:[NSNumber class]]){
                double doubleValue = [value doubleValue];
                realValue = [NSNumber numberWithDouble:doubleValue];
            }else{
                realValue = value;
            }
            return realValue;
        };
        [keyValues addObject:keyV];
    }];
    return keyValues;
}
+(ImageMessage *)parserWithKeys:(NSArray *)keys Content:(NSString *)content {
    //image<image src=\"sss\" width=\"\" height=\"\">
    ImageMessage *imgMsg = [[ImageMessage alloc]init];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *pattern = [NSString stringWithFormat:@"(?<=%@=\")(\\w+|\\.|\\:|\\/)+",key];
        NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:0 error:nil];
        NSTextCheckingResult *result = [regular firstMatchInString:content options:0 range:NSMakeRange(0, content.length)];
        NSString *conRes = [content substringWithRange:result.range];
        [imgMsg setValue:conRes forKey:key];
    }];
    return imgMsg;
}
+(CoreTextData *)parserWithPropertyContent:(NSString *)content  defaultConfig:(FrameParserConfig *)defaultConfig{
    //  1：文本的分块操作
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    CoreTextData *data = [self parserContent:content defaultConfig:defaultConfig  sectionHandle:regular partContentDeal:^Message *(NSString * onepart) {
        Message *result;
        SourceType type = [onepart containsString:@"<font"]?textType:imageType;
        if (type == textType) {
            TextMessage *partC =[[TextMessage alloc]init];
            partC.paragraConfig = [[paragraphConfig alloc]init];
            partC.content = onepart;
            partC.type = type;
            //2：需要解析的关键字
            NSArray<NSString *> *keys = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyword_keyPath_text" ofType:@"plist"]] allKeys];
            partC.keyValues = [self parserKeyValuesWithKeys:keys content:onepart];
            result = partC;
        }else{
             NSArray<NSString *> *keys = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyword_keyPath_image" ofType:@"plist"]] allKeys];
            ImageMessage *imgMSg = [self parserWithKeys:keys Content:onepart];
            imgMSg.type = type;
            imgMSg.content = onepart;
            result = imgMSg;
        }
        result.parserHandle = ^NSString *(SourceType type,NSString *content){
            if (type==textType){
                return  (NSString *)[[content componentsSeparatedByString:@"<"] firstObject];
            }else if (type == imageType){
                return @" "; //图片占位字符   长度必须大于等于1
            }
            return @"";
        };
        return result;
    }];
    return data;
}
@end

@implementation FrameParser (CallBack)
+(CoreTextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC  callBack:(parserCallBacks)calls{
    CoreTextData *data =[[CoreTextData alloc]init];
    NSMutableArray<Message *> *msgArr = [NSMutableArray array];
    NSMutableArray<NSString *> *allPart =  calls.contentBack(content);
    if (allPart.lastObject.length==0) {[allPart removeLastObject]; }
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc]init];
    CGSize size = defaultC.contentSize;
    [allPart enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Message *pConfig = calls.sectionBack(obj,calls.valueBack);
        pConfig.showBack = calls.showContentBack;
        if (pConfig.type == textType) {
            TextMessage *TConfig = (TextMessage *)pConfig;
            NSString *showContent = calls.showContentBack(pConfig.type,obj);
            FrameParserConfig *config = [FrameParserConfig defaultConfigWithContentSize:size];
            NSDictionary *dic = [TConfig partAttribute:config];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            TConfig.contentRange = NSMakeRange(contentAtt.string.length, showContent.length);
            [contentAtt appendAttributedString:oneAtt];
        }else{
            ImageMessage *imgMsg = (ImageMessage *)pConfig;
            NSString *showCon = calls.showContentBack(imgMsg.type,obj);
            NSDictionary *dic = [imgMsg partAttribute];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:showCon attributes:dic];
            imgMsg.contentRange =NSMakeRange(contentAtt.string.length, showCon.length);
            [contentAtt appendAttributedString:oneAtt];
        }
        [msgArr addObject:pConfig];
    }];
    CTFramesetterRef setter =CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentAtt);
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !defaultC.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    data.contentString = contentAtt.string;
    data.msgArray= msgArr;
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.frameRef = frameRef;
    data.realContentHeight = contSize.height;
    CFRelease(setter);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return data;
}
+(CoreTextData *)parserWithPropertyContent2:(NSString *)content  defaultConfig:(FrameParserConfig *)defaultConfig{
    parserCallBacks callBacks;
    callBacks.contentBack = contentSplit;
    callBacks.sectionBack = parserSection;
    callBacks.showContentBack = parserShowContent;
    callBacks.valueBack = getRealValue;
    return [self parserContent:content defaultConfig:defaultConfig  callBack:callBacks];
}
@end

