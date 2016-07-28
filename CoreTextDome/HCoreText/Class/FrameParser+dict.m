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
#import "NSString+HEmoji.h"
@implementation FrameParser (dict)
static NSMutableArray *textkeywords;
static NSMutableArray *linkkeywords;
static NSMutableArray *imagekeywords;
static NSMutableArray *videokeywords;
+(void)loadData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath_text.plist" ofType:nil];
    NSArray *textkeys = [[NSDictionary dictionaryWithContentsOfFile:path] allKeys];
    textkeywords=textkeys.mutableCopy;
    
    linkkeywords=[NSMutableArray arrayWithArray:textkeywords];
    [linkkeywords addObject:@"URLSrc"];
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath_image.plist" ofType:nil];
    NSArray *textkeys2 = [[NSDictionary dictionaryWithContentsOfFile:path2] allKeys];
    imagekeywords=textkeys2.mutableCopy;
    
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"keyword_keyPath_video.plist" ofType:nil];
    NSArray *textkeys3 = [[NSDictionary dictionaryWithContentsOfFile:path3] allKeys];
    videokeywords=textkeys3.mutableCopy;
}
+(SourceType)gettype:(NSString *)typeStr{
    if ([[typeStr lowercaseString] isEqualToString:@"text"]) {
        return TextType;
    }else if([[typeStr lowercaseString] isEqualToString:@"image"]) {
        return ImageType;
    }else if([[typeStr lowercaseString] isEqualToString:@"link"]){
        return LinkType;
    }else if([[typeStr lowercaseString] isEqualToString:@"video"]){
        return VideoType;
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
+(ImageMessage *)parserWithDic:(NSDictionary *)contentDic type:(SourceType)type defaultCfg:(FrameParserConfig *)cfg{
    NSMutableDictionary *dic = contentDic.mutableCopy;
    [dic removeObjectForKey:@"content"];
    [dic removeObjectForKey:@"type"];
    NSArray *keys=dic.allKeys;
    void (^Block)(ImageMessage *img)=^(ImageMessage *img){
        if (![keys containsObject:@"isReturn"]) {
            switch (type==ImageType?cfg.imageShowType:cfg.videoShowType) {
                case originality:
                    break;
                case defaultReturn:
                    [img setValue:@(1) forKey:@"isReturn"];
                    break;
                case returnCenter:
                    [img setValue:@(1) forKey:@"isReturn"];
                    [img setValue:@(1) forKey:@"isCenter"];
                    break;
            }
        }

        if (![keys containsObject:@"isCenter"]) {
            switch (type==ImageType?cfg.imageShowType:cfg.videoShowType) {
                case originality:
                    break;
                case defaultReturn:
                    [img setValue:@(1) forKey:@"isReturn"];
                    break;
                case returnCenter:
                    [img setValue:@(1) forKey:@"isReturn"];
                    [img setValue:@(1) forKey:@"isCenter"];
                    break;
            }
        }
        if(![keys containsObject:@"isSingleLine"]){
            [img setValue:@(1) forKey:@"isReturn"];
            [img setValue:@(1) forKey:@"isCenter"];
            [img setValue:@(cfg.integrate) forKey:@"isSingleLine"];
        }
        
    };
    
    ImageMessage *imgMsg;
    if (type==ImageType) {
        imgMsg = [[ImageMessage alloc]init];
    }else{
        imgMsg = [[VideoMessage alloc]init];
    }
    Block(imgMsg);
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([imagekeywords containsObject:key])
            [imgMsg setValue:obj forKey:key];
    }];
    return imgMsg;
}
+(CoreTextData *)parserWithSource:(NSArray<NSDictionary<NSString * ,NSString *>*> *)content defaultCfg:(FrameParserConfig *)defaultC{
    [self loadData];
    CoreTextData *data = [[CoreTextData alloc]init];
    NSMutableAttributedString *contAtt = [[NSMutableAttributedString alloc]init];
    NSMutableArray<Message *> *msgArray = [NSMutableArray array];
    void(^dealEmoji)(NSMutableAttributedString *string,NSMutableArray *ranges)=^(NSMutableAttributedString *string,NSMutableArray<NSValue *>*ranges){
        if (!defaultC.integrate) {
            [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range=[obj rangeValue];
                [string setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:defaultC.emojiZise]} range:range];
            }];
        }
    };
    
    [content enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSString *> * _Nonnull oneDic, NSUInteger idx, BOOL * _Nonnull stop) {
        SourceType type = [self gettype:oneDic[@"type"]];
        NSString *showContent = oneDic[@"content"];
        if (type==TextType) {
            TextMessage *textMsg =[[TextMessage alloc]init];
            showContent = [showContent emojizedStringWithCurrent:textMsg];
            textMsg.keyValues = [self parserKeyValuesWithDic:oneDic type:type];
            textMsg.type = type;
            NSDictionary *dic = [textMsg partAttribute:defaultC.fontCig];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:showContent attributes:dic];
            dealEmoji(attStr,textMsg.emojiRange);
            textMsg.attSring= attStr;
            textMsg.contentRange = NSMakeRange(contAtt.length, showContent.length);
            [contAtt appendAttributedString:attStr];
            [msgArray addObject:textMsg];
        }else if(type == LinkType){
            TextLinkMessage *link = [[TextLinkMessage alloc]init];
            showContent = [showContent emojizedStringWithCurrent:link];
            link.type= LinkType;
            link.keyValues =[self parserKeyValuesWithDic:oneDic type:type];
            NSDictionary *dic = [link partAttribute:defaultC.fontCig];
            NSMutableAttributedString *one = [[NSMutableAttributedString alloc]initWithString:showContent attributes:dic];
            dealEmoji(one,link.emojiRange);
            link.attSring=one;
            link.contentRange = NSMakeRange(contAtt.length, one.length);
            [contAtt appendAttributedString:one];
            [msgArray addObject:link];
        }else if(type==ImageType|type==VideoType){
            ImageMessage *imgMsg = [self parserWithDic:oneDic type:type defaultCfg:defaultC];
            imgMsg.type = type;
            showContent=@" ";
            void(^Block)(void)  = ^{
                Message *last = [msgArray lastObject];
                if ([last.attSring.string isEqualToString:@"\n"]) {
                    return ;
                }
                TextMessage *message = [[TextMessage alloc]init];
                message.type=TextType;
                message.contentRange=NSMakeRange(contAtt.length,1);
                NSMutableAttributedString *att =[[NSMutableAttributedString alloc]initWithString:@"\n" attributes:nil];
                message.attSring=att;
                [contAtt appendAttributedString:att];
                [msgArray addObject:message];
            };
            if ([showContent hasPrefix:@"\n"]) {
                Block();
            }else if(imgMsg.type==ImageType&&imgMsg.isReturn&&msgArray.count>=1) {
                Block();
            }else if (imgMsg.type==VideoType&&imgMsg.isReturn&&msgArray.count>=1){
                Block();
            }
            
            
            NSDictionary *dic = [imgMsg partAttribute];
            NSMutableAttributedString *one = [[NSMutableAttributedString alloc]initWithString:showContent attributes:dic];
            imgMsg.attSring = one;
            imgMsg.contentRange = NSMakeRange(contAtt.length, one.length);
            [contAtt appendAttributedString:one];
            [msgArray addObject:imgMsg];
            
            
            if(imgMsg.isCenter) {
                Block();
            }
        }
        
        
        
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
