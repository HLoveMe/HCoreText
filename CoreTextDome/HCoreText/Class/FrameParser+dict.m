//
//  FrameParser+dict.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/18.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParser+dict.h"
#import "FrameParserConfig.h"
#import "CoreTextData.h"
#import "partMessage.h"
#import "UIColor+Hex.h"
#import "paragraphConfig.h"
#import "ParserType.h"
#import "ParserType.h"
@implementation FrameParser (dict)
static NSMutableArray *textkeywords;
static NSMutableArray *linkkeywords;
static NSMutableArray *imagekeywords;
+(void)load{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath_text.plist" ofType:nil];
    NSArray *textkeys = [[NSDictionary dictionaryWithContentsOfFile:path] allKeys];
    textkeywords=textkeys.mutableCopy;
    
    linkkeywords=[NSMutableArray arrayWithArray:textkeywords];
    [linkkeywords addObject:@"URLSrc"];
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath_image.plist" ofType:nil];
    NSArray *textkeys2 = [[NSDictionary dictionaryWithContentsOfFile:path2] allKeys];
    imagekeywords=textkeys2.mutableCopy;
}
+(SourceType)gettype:(NSString *)typeStr{
    if ([[typeStr lowercaseString] isEqualToString:@"text"]) {
        return TextType;
    }else if([[typeStr lowercaseString] isEqualToString:@"image"]) {
        return ImageType;
    }else if([[typeStr lowercaseString] isEqualToString:@"link"]){
        return LinkType;
    }else{
        NSAssert(false, @"type 关键字错误");
        return 1;
    }
}

+(keyValue *)getOneKeyValue:(NSString *)key content:(NSString *)content value:(NSString *)value {
    keyValue *one = [[keyValue alloc]init];
    one.keyword = key;
    one.content= content;
    one.value = value;
    one.valueHandle = ^id(NSString *key, NSString *value, __unsafe_unretained Class clazz) {
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
    return one;
}

+(NSArray<keyValue*>*)parserKeyValuesWithDic:(NSDictionary *)contentDic type:(SourceType)type{
    NSMutableDictionary *dic = contentDic.mutableCopy;
    NSString *showContent = [contentDic objectForKey:@"content"];
    NSAssert(showContent, @"content关键字必须的");
    [dic removeObjectForKey:@"content"];
    [dic removeObjectForKey:@"type"];
    
    NSMutableArray *keyValues = [NSMutableArray array];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString *value, BOOL * _Nonnull stop) {
        keyValue *one;
        if (type==TextType) {
            if ([textkeywords containsObject:key]) {
                one = [self getOneKeyValue:key content:showContent value:value];
            }
        }else if(type==LinkType){
            if ([linkkeywords containsObject:key]) {
                one = [self getOneKeyValue:key content:showContent value:value];
            }
        }
        if (one)[keyValues addObject:one];
    }];
    return keyValues;
}
+(ImageMessage *)parserWithDic:(NSDictionary *)contentDic{
    NSMutableDictionary *dic = contentDic.mutableCopy;
    [dic removeObjectForKey:@"content"];
    [dic removeObjectForKey:@"type"];
    ImageMessage *imgMsg = [[ImageMessage alloc]init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([imagekeywords containsObject:key])
        [imgMsg setValue:obj forKey:key];
    }];
    return imgMsg;
}
+(CoreTextData *)parserWithSource:(NSArray<NSDictionary<NSString * ,NSString *>*> *)content defaultCfg:(FrameParserConfig *)defaultC{
    CoreTextData *data = [[CoreTextData alloc]init];
    NSMutableAttributedString *contAtt = [[NSMutableAttributedString alloc]init];
    NSMutableArray<Message *> *msgArray = [NSMutableArray array];
    [content enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSString *> * _Nonnull oneDic, NSUInteger idx, BOOL * _Nonnull stop) {
        SourceType type = [self gettype:oneDic[@"type"]];
        Message *msg;
        NSString *showContent = oneDic[@"content"];
        if (type==TextType) {
            TextMessage *textMsg =[[TextMessage alloc]init];
            textMsg.keyValues = [self parserKeyValuesWithDic:oneDic type:type];
            textMsg.type = type;
            NSDictionary *dic = [textMsg partAttribute:defaultC.fontCig];
            NSAttributedString *attStr = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            textMsg.attSring= attStr;
            textMsg.contentRange = NSMakeRange(contAtt.length, showContent.length);
            [contAtt appendAttributedString:attStr];
            msg=textMsg;
        }else if(type == LinkType){
            TextLinkMessage *link = [[TextLinkMessage alloc]init];
            link.type= LinkType;
            link.keyValues =[self parserKeyValuesWithDic:oneDic type:type];
            NSDictionary *dic = [link partAttribute:defaultC.fontCig];
            NSAttributedString *one = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            link.attSring=one;
            link.contentRange = NSMakeRange(contAtt.length, one.length);
            [contAtt appendAttributedString:one];
            msg = link;
        }else{
            ImageMessage *imgMsg = [self parserWithDic:oneDic];
            imgMsg.type = type;
            NSDictionary *dic = [imgMsg partAttribute];
            if (!showContent||showContent.length==0) {
                showContent=@" ";
            }
            NSAttributedString *one = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            imgMsg.attSring = one;
            imgMsg.contentRange = NSMakeRange(contAtt.length, one.length);
            [contAtt appendAttributedString:one];
            msg = imgMsg;
        }
        
        [msgArray addObject:msg];
        
    }];
    CGSize size  = defaultC.contentSize;
    CTFramesetterRef sett = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contAtt);
    CGSize contentSize = CTFramesetterSuggestFrameSizeWithConstraints(sett, CFRangeMake(0, 0), nil, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !defaultC.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contentSize.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, rect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(sett, CFRangeMake(0, 0), path, nil);
    data.parserCfg = defaultC;
    data.contentString = contAtt;
    data.msgArray =msgArray;
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.realContentHeight = contentSize.height;
    data.frameRef = frameRef;
    
    CFRelease(sett);
    CFRelease(path);
    CFRelease(frameRef);

    return data;
}
@end
