//
//  FrameParser+callBack.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/18.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParser+callBack.h"
#import "FrameParserConfig.h"
#import "CoreTextData.h"
#import "partMessage.h"
#import "UIColor+Hex.h"
#import "ValueParser.h"
#import "specialDeal.h"
#import "paragraphConfig.h"
@implementation FrameParser (callBack)
+(CoreTextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC  callBack:(parserCallBacks)calls{
    CoreTextData *data =[[CoreTextData alloc]init];
    NSMutableArray<Message *> *msgArr = [NSMutableArray array];
    NSMutableArray<NSString *> *allPart =  calls.contentBack(content);
    if (allPart.lastObject.length==0) {[allPart removeLastObject]; }
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc]init];
    CGSize size = defaultC.contentSize;
    [allPart enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keywords = calls.keywordsBack(obj);
        Message *pConfig = calls.sectionBack(obj,keywords,calls.valueBack);
        pConfig.showBack = calls.showContentBack;
        if (pConfig.type == TextType) {
            TextMessage *TConfig = (TextMessage *)pConfig;
            NSString *showContent = calls.showContentBack(pConfig.type,obj);
            FrameParserConfig *config = [FrameParserConfig defaultConfigWithContentSize:size];
            NSDictionary *dic = [TConfig partAttribute:config.fontCig];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            TConfig.contentRange = NSMakeRange(contentAtt.string.length, showContent.length);
            TConfig.attSring= oneAtt;
            [contentAtt appendAttributedString:oneAtt];
        }else if(pConfig.type == ImageType){
            ImageMessage *imgMsg = (ImageMessage *)pConfig;
            NSString *showCon = calls.showContentBack(imgMsg.type,obj);
            NSDictionary *dic = [imgMsg partAttribute];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:showCon attributes:dic];
            imgMsg.contentRange =NSMakeRange(contentAtt.string.length, showCon.length);
            imgMsg.attSring = oneAtt;
            [contentAtt appendAttributedString:oneAtt];
        }else if(pConfig.type == LinkType){
            TextLinkMessage *link = (TextLinkMessage *)pConfig;
            NSString *showContent = calls.showContentBack(pConfig.type,obj);
            FrameParserConfig *config = [FrameParserConfig defaultConfigWithContentSize:size];
            NSDictionary *dic = [link partAttribute:config.fontCig];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            link.contentRange = NSMakeRange(contentAtt.string.length, showContent.length);
            link.attSring= oneAtt;
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
    data.parserCfg = defaultC;
    data.contentString = contentAtt;
    data.msgArray= msgArr;
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.frameRef = frameRef;
    data.realContentHeight = contSize.height;
    CFRelease(setter);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return data;
}
+(CoreTextData *)parserWithPropertyContent2:(NSString *)content defaultCfg:(FrameParserConfig *)defaultConfig{
    parserCallBacks callBacks;
    callBacks.contentBack = contentSplit;
    callBacks.sectionBack = parserSection;
    callBacks.showContentBack = parserShowContent;
    callBacks.keywordsBack = keyWordParser;
    callBacks.valueBack = getRealValue;
    return [self parserContent:content defaultConfig:defaultConfig  callBack:callBacks];
}
@end