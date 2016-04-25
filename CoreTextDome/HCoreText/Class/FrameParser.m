//
//  FrameParser.m
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "FrameParser.h"
#import "FrameParserConfig.h"
#import "CoretextData.h"
#import "partConfig.h"
#import "UIColor+Hex.h"
#import "ValueParser.h"
#import "specialDeal.h"
@implementation FrameParser
+(NSMutableDictionary *)attributeWithConfig:(FrameParserConfig *)config{
    CTFontRef font = (__bridge CTFontRef)(config.font);
    CGFloat line = config.LineSpace;
    uint8_t CharWrapping=kCTLineBreakByCharWrapping;
    uint8_t Alignment =  kCTTextAlignmentLeft;
    CGFloat firstIndent = config.firstLineIndent;
    //段落样式设置   换行 间距  对齐 等等
    CTParagraphStyleSetting settings[6] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&line},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&line},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&line},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(uint8_t),&CharWrapping},
        {kCTParagraphStyleSpecifierAlignment,sizeof(uint8_t),&Alignment},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(CGFloat),&firstIndent}
    };
    //段落样式
    CTParagraphStyleRef styleRef =CTParagraphStyleCreate(settings,6);
    //整体样式  文字 颜色 等等
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[(id)kCTFontAttributeName] = (__bridge id _Nullable)(font);
    dic[(id)kCTForegroundColorAttributeName] =  (__bridge id _Nullable)(config.textColor.CGColor);
    dic[(id)kCTParagraphStyleAttributeName]= (id)styleRef;
    CFRelease(styleRef);
    return dic;
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
+(CoretextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC contenSize:(CGSize)size sectionHandle:(NSRegularExpression *)handle partContentDeal:(partConfig *(^)(NSString * onepart))parthandle {
    NSMutableArray *contentResult = [[handle matchesInString:content options:0 range:NSMakeRange(0, content.length)] mutableCopy];
    [contentResult removeLastObject];
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc]init];
    [contentResult enumerateObjectsUsingBlock:^(NSTextCheckingResult  *result, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *obj = [content substringWithRange:result.range];
        NSAssert(parthandle, @"parthandle is nil error");
        partConfig *pConfig = parthandle(obj);
        /**得到显示的文本*/
        if (pConfig.type == textType) {
            NSString *oneCont = pConfig.parserHandle(pConfig.type,pConfig.content);
            FrameParserConfig *config = [FrameParserConfig defaultConfig];
            [pConfig.keyValues enumerateObjectsUsingBlock:^(keyValue * _Nonnull keyValue, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = keyValue.valueHandle(keyValue.keyword,keyValue.value,keyValue.clazz);
                [config setValue:value forKeyPath:keyValue.keyPath];
            }];
            NSDictionary *dic =[self attributeWithConfig:config];
            NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:oneCont attributes:dic];
            [contentAtt appendAttributedString:oneAtt];
        }else{
#warning 图片处理
//            [contentAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"<image>"]];
        }
        
    }];
    CTFramesetterRef setter =CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentAtt);
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !defaultC.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    CoretextData *data =[[CoretextData alloc]init];
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.frameRef = frameRef;
    data.realContentHeight = contSize.height;
    CFRelease(setter);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return data;
}

+(CoretextData *)parserWithPropertyContent:(NSString *)content contentSize:(CGSize)size defaultConfig:(FrameParserConfig *)defaultConfig useingParameters:(keywordsBlock) keywords{
    //  1：文本的分块操作
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    CoretextData *data = [self parserContent:content defaultConfig:defaultConfig contenSize:size sectionHandle:regular partContentDeal:^partConfig *(NSString * onepart) {
        partConfig *partC =[[partConfig alloc]init];
        partC.content = onepart;
        partC.type = [onepart containsString:@"<font"]?textType:imageType;
        partC.parserHandle = ^NSString *(SourceType type,NSString *content){
            if (type==textType){
                return  (NSString *)[[content componentsSeparatedByString:@"<"] firstObject];
            }else if (type == imageType){
                return  @" "; //图片占位字符   长度必须大于等于1
            }
            return @"";
        };
        NSMutableArray *keyValues  =[NSMutableArray array];
        NSAssert(keywords,@"keywords can't null");
        //2：需要解析的关键字
        NSArray<NSString *> *keys = keywords(partC.type , onepart);
        [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            keyValue *keyV = [[keyValue alloc]init];
            keyV.keyword = obj;
            keyV.content = onepart;
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
        partC.keyValues = keyValues;
        return partC;
    }];
    return data;
}
+(CoretextData *)parseContent:(NSString *)content contentSize:(CGSize)size withConfig:(FrameParserConfig *)config{
    NSDictionary *dic = [self attributeWithConfig:config];
    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:content attributes:dic];
    
    CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    /**计算需要的空间*/
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !config.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    CoretextData *data = [[CoretextData alloc]init];
    [data setValue:@(config.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.realContentHeight = size.height;
    data.frameRef = frameRef;
    CFRelease(setter);
    CFRelease(pathRef);
    return data;
}



//+(CoretextData *)parseAtributeString:(NSAttributedString *)content withConfig:(FrameParserConfig *)config{
////     id a =[content valueForKey:@"atts"];
////    NSAttributedString *att = [[NSAttributedString alloc]initWithString:<#(nonnull NSString *)#> attributes:<#(nullable NSDictionary<NSString *,id> *)#>]
//    CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
//    /**计算需要的空间*/
//    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(config.contentRect.size.width, CGFLOAT_MAX), nil);
//
//    //创建CTFrame
//    CGRect rect = !config.autoAdjustHeight?config.contentRect:CGRectMake(0, 0, config.contentRect.size.width, size.height);
//    CGMutablePathRef pathRef = CGPathCreateMutable();
//    CGPathAddRect(pathRef, NULL, rect);
//
//    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
//    CoretextData *data = [[CoretextData alloc]init];
//    [data setValue:@(config.autoAdjustHeight) forKey:@"autoAdjustHeight"];
//    data.realContentHeight = size.height;
//    data.frameRef = frameRef;
//    CFRelease(setter);
//    CFRelease(pathRef);
//    return data;
//}

@end

@implementation FrameParser (CallBack)
+(CoretextData *)parserContent:(NSString *)content defaultConfig:(FrameParserConfig *)defaultC contenSize:(CGSize)size callBack:(parserCallBacks)calls{
    NSMutableArray<NSString *> *allPart =  calls.contentBack(content);
    if (allPart.lastObject.length==0) {[allPart removeLastObject]; }
    NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc]init];
    [allPart enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        partConfig *pConfig = calls.sectionBack(obj);  //解析出是什么类型  text  image
        NSString *showContent = calls.showContentBack(pConfig.type,obj);
        FrameParserConfig *config = [FrameParserConfig defaultConfig];
        [pConfig.keyValues enumerateObjectsUsingBlock:^(keyValue * _Nonnull keyValue, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = calls.valueBack(keyValue.keyword,keyValue.value,keyValue.clazz);
            [config setValue:value forKeyPath:keyValue.keyPath];
        }];
        NSDictionary *dic =[self attributeWithConfig:config];
        NSAttributedString *oneAtt = [[NSAttributedString alloc]initWithString:showContent attributes:dic];
        [contentAtt appendAttributedString:oneAtt];
    }];
    CTFramesetterRef setter =CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentAtt);
    CGSize contSize= CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), nil);
    CGRect rect = !defaultC.autoAdjustHeight?CGRectMake(0, 0, size.width, size.height):CGRectMake(0, 0,size.width, contSize.height);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), pathRef, NULL);
    CoretextData *data =[[CoretextData alloc]init];
    [data setValue:@(defaultC.autoAdjustHeight) forKey:@"autoAdjustHeight"];
    data.frameRef = frameRef;
    data.realContentHeight = contSize.height;
    CFRelease(setter);
    CFRelease(pathRef);
    CFRelease(frameRef);
    return data;
}
+(CoretextData *)parserWithPropertyContent:(NSString *)content contentSize:(CGSize)size defaultConfig:(FrameParserConfig *)defaultConfig{
    parserCallBacks callBacks;
    callBacks.contentBack = contentSplit;
    callBacks.sectionBack = parserSection;
    callBacks.showContentBack = parserShowContent;
    callBacks.valueBack = getRealValue;
    return [self parserContent:content defaultConfig:defaultConfig contenSize:size callBack:callBacks];
}
@end

