//
//  FrameParserObject.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/11.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParserHandle.h"
#import "partMessage.h"
#import "UIColor+Hex.h"
@implementation FrameParserHandle
-(NSMutableArray<NSString *>*)parserWithContent:(NSString *)conent{
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray<NSTextCheckingResult *> *result =  [regular matchesInString:conent options:NSMatchingReportProgress range:NSMakeRange(0, conent.length)];
    NSMutableArray<NSString *> *strs = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *con = [conent substringWithRange:obj.range];
        if (con.length>=1) {
            [strs addObject:con];
        }
       
    }];
    return strs;
}
-(NSArray <NSString *>*)parserKeywordWithPartText:(NSString *)partText type:(SourceType)type{
    //<link url=\"http://www.baidu.com\" name=\"Futura\" size=\"20\" color=\"blue\" >
    NSMutableArray *keywords = [NSMutableArray array];
    NSRegularExpression * regular = [NSRegularExpression regularExpressionWithPattern:@"\\b\\w+(?==)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray <NSTextCheckingResult *>*results = [regular matchesInString:partText options:NSMatchingReportProgress range:NSMakeRange(0, partText.length)];
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [keywords addObject:[partText substringWithRange:obj.range]];
    }];
    return keywords;
}

-(Message *)parserMessageWithPartText:(NSString *)partText{
    SourceType type;
    if ([self respondsToSelector:@selector(parserTypeWithPart:)]) {
       type = [self parserTypeWithPart:partText];
    }else{
        if ([partText containsString:@"<font"]) {
            type = TextType;
        }else if([partText containsString:@"<link"]){
            type = LinkType;
        }else{
            type = ImageType;
        }
    }
    Message *msg ;
    if (type==TextType) {
        TextMessage *textMsg = [[TextMessage alloc]init];
        textMsg.type = type;
        NSArray<NSString *>* keys =[self parserKeywordWithPartText:partText type:type];
        textMsg.keyValues = [self parserKeyValuesWithKeys:keys content:partText];
        msg = textMsg;
    }else if(type == LinkType){
        TextLinkMessage *link = [[TextLinkMessage alloc]init];
        link.type= LinkType;
        NSArray<NSString *>* keys =[self parserKeywordWithPartText:partText type:type];
        link.keyValues = [self parserKeyValuesWithKeys:keys content:partText];
        msg = link;
    }else if(type==ImageType){
        NSArray<NSString *>* keys =[self parserKeywordWithPartText:partText type:type];
        ImageMessage *imgMsg = [self parserWithKeys:keys Content:partText];
        imgMsg.type = type;
        msg = imgMsg;
    }
    
    return msg;
}

//-(SourceType)parserTypeWithPart:(NSString *)partText{}
//-(NSString *)parserShowText:(SourceType)type text:(NSString *)onePart{}



-(NSMutableArray <keyValue *>*)parserKeyValuesWithKeys:(NSArray<NSString *>*)keys content:(NSString *)content{
    NSMutableArray *keyValues  =[NSMutableArray array];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        keyValue *keyV = [[keyValue alloc]init];
        keyV.keyword = obj;
        keyV.content = content;
        //3：怎么通过关键字 从文本中解析到对应的值
        NSString *Pattern = [NSString stringWithFormat:@"(?<=%@=\")(\\w+|\\.|\\:|\\/)+",obj];
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
-(ImageMessage *)parserWithKeys:(NSArray *)keys Content:(NSString *)content {
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
@end
