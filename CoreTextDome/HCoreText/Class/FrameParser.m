
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
#import "paragraphConfig.h"
#import "FrameParserHandle.h"
#import "NSString+HEmoji.h"
#import <objc/runtime.h>
@implementation FrameParser
+(CoreTextData *)parserContent:(NSString *)content withConfig:(FrameParserConfig *)config{
    NSDictionary *dic = [config defaultAttribute];
    content = [content emojizedString];
    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:content attributes:dic];
    TextMessage *textMsg = [[TextMessage alloc]init];
    textMsg.type = TextType;
    textMsg.contentRange = NSMakeRange(0, content.length);
    textMsg.attSring = attString;
    CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    /**计算需要的空间*/
    CGSize size = config.contentSize;
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !config.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    CoreTextData *data = [[CoreTextData alloc]init];
    data.parserCfg = config;
    data.contentString = attString;
    [data setValue:@(config.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.realContentHeight = contSize.height;
    data.frameRef = frameRef;
    data.msgArray = [NSMutableArray arrayWithObject:textMsg];
    CFRelease(setter);
    CFRelease(pathRef);
    return data;
}
+(CoreTextData *)parserContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC parserDelegate:(id<FrameParserDelegate>)delegate{
    NSAssert(delegate, @"FrameParserDelegate can not is nil");
    NSMutableArray<NSString *> *parts = [delegate parserWithContent:content];
    CoreTextData *data =[[CoreTextData alloc]init];
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc]init];
    NSMutableArray *msgArray = [NSMutableArray array];
    [parts enumerateObjectsUsingBlock:^(NSString * _Nonnull onePart, NSUInteger idx, BOOL * _Nonnull stop) {
        Message *msg = [delegate parserMessageWithPartText:onePart withDefault:defaultC];
        if (msg.type==TextType) {
            TextMessage *textMsg = (TextMessage *)msg;
            NSString *showContent;
            if([delegate respondsToSelector:@selector(parserShowText:text:)]){
                showContent = [delegate parserShowText:TextType text:onePart];
            }else{
                showContent= (NSString *)[[onePart componentsSeparatedByString:@"<text"] firstObject];
            }
            showContent = [showContent emojizedString];
            NSDictionary *dic = [textMsg partAttribute:defaultC.fontCig];
            NSAttributedString *one = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            textMsg.attSring=one;
            textMsg.contentRange = NSMakeRange(contentAtt.length, one.length);
            [contentAtt appendAttributedString:one];
            [msgArray addObject:msg];
        }else if (msg.type==ImageType|msg.type==VideoType){
            ImageMessage *imgMsg = (ImageMessage *)msg;
            NSString *showContent=@" ";
            void(^Block)(void)  = ^{
                Message *last = [msgArray lastObject];
                if ([last.attSring.string isEqualToString:@"\n"]) {
                    return ;
                }
                TextMessage *message = [[TextMessage alloc]init];
                message.type=TextType;
                message.contentRange=NSMakeRange(contentAtt.length,1);
                NSAttributedString *att =[[NSAttributedString alloc]initWithString:@"\n" attributes:nil];
                message.attSring=att;
                [contentAtt appendAttributedString:att];
                [msgArray addObject:message];
            };
            if ([onePart hasPrefix:@"\n"]) {
                Block();
            }else if(msg.type==ImageType&&imgMsg.isReturn&&msgArray.count>=1) {
                Block();
            }else if (msg.type==VideoType&&imgMsg.isReturn&&msgArray.count>=1){
                Block();
            }
            NSDictionary *dic = [imgMsg partAttribute];
            NSAttributedString *one = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            imgMsg.attSring = one;
            imgMsg.contentRange = NSMakeRange(contentAtt.length, one.length);
            [contentAtt appendAttributedString:one];
            [msgArray addObject:msg];
            
            
            if(imgMsg.isCenter) {
                Block();
            }
        }else if(msg.type==LinkType){
            TextLinkMessage *linkMsg = (TextLinkMessage *)msg;
            NSString *showContent;
            if([delegate respondsToSelector:@selector(parserShowText:text:)]){
                showContent = [delegate parserShowText:TextType text:onePart];
            }else{
                showContent= (NSString *)[[onePart componentsSeparatedByString:@"<link"] firstObject];
            }
            showContent = [showContent emojizedString];
            NSDictionary *dic = [linkMsg partAttribute:defaultC.fontCig];
            NSAttributedString *one = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
            linkMsg.attSring=one;
            linkMsg.contentRange = NSMakeRange(contentAtt.length, one.length);
            [contentAtt appendAttributedString:one];
            [msgArray addObject:msg];
        }
    }];
    CGSize size  = defaultC.contentSize;
    CTFramesetterRef sett = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentAtt);
    CGSize contentSize = CTFramesetterSuggestFrameSizeWithConstraints(sett, CFRangeMake(0, 0), nil, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !defaultC.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contentSize.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, rect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(sett, CFRangeMake(0, 0), path, nil);
    data.parserCfg = defaultC;
    data.contentString = contentAtt;
    data.msgArray =msgArray;
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.realContentHeight = contentSize.height;
    data.frameRef = frameRef;
    
    CFRelease(sett);
    CFRelease(path);
    CFRelease(frameRef);
    return data;
}
+(CoreTextData *)parserWithPropertyContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC{
    return [self parserContent:content defaultCfg:defaultC parserDelegate:[[FrameParserHandle alloc]init]];
}
@end



