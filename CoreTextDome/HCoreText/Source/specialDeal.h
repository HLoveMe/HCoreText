//
//  specialDeal.h
//  CoreTextDome
//
//  Created by space on 16/4/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//
/**
 *  对于特殊的文本解析 给出一个解析实例
 *  如果你所需要解析的文本和该格式一致(或者按照该格式创建你的文本)那么你就可以直接使用
 *  这些C++函数来作为你的解析器参数 。或者重写struct parserCallBacks对应的函数
 *  note:如果你使用了这些函数作为你的解析函数 那么你需要具体需求改变某些参数
 修改该函数即可:
 *       static partConfig * parserSection(NSString *partString )
 *  格式
 *  @"I<font name=\"Futura\" size=\"20\" color=\"blue\" >Love <font name=\"Futura\" size=\"12\" color=\"red\"><img src=\"\" width=\"\" height=\"\">you<font name=\"Futura\" size=\"25\">"
 *   @“文本<文本配置><图片配置>文本(文本配置)。。。”
 *  @return
 */
#ifndef specialDeal_h
#define specialDeal_h
#import <UIKit/UIKit.h>
#import "partMessage.h"
/**
 *  用于回调 把整个文本 按照开发者的需求分割为 几个片段（将要显示的内容 和 该内容的配置信息 的结合）
 *
 *  @param parserContentSplitBack
 *
 *  @return 片段集合
 */
static NSMutableArray<NSString *>*  contentSplit(NSString *wholeContent){
    NSMutableArray *stringArray = [NSMutableArray array];
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSMutableArray *contentResult = [[regular matchesInString:wholeContent options:0 range:NSMakeRange(0, wholeContent.length)] mutableCopy];
    [contentResult removeLastObject]; //最后一个空白元素
    [contentResult enumerateObjectsUsingBlock:^(NSTextCheckingResult  *result, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *temp = [wholeContent substringWithRange:result.range];
        [stringArray addObject:temp];
    }];
    return stringArray;
}
/**
 *  给定某个片段的内容 创建属于该片段的 partConfig对象
 *
 *  @param parserSectionCallBack
 *
 *  @return
 */
static Message * parserSection(NSString *partString,parserValueCallBack valueBack){
    Message *result;
    /**该文本的内容*/
    SourceType type = [partString containsString:@"<font"]?textType:imageType;
    if (type== textType) {
        TextMessage *config = [[TextMessage alloc]init];
        config.content = partString;
        config.type = type;
        /**配置的关键字*/
        NSArray *keywords =[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyword_keyPath_text" ofType:@"plist"]] allKeys];
        NSMutableArray<keyValue *>* keyVs = [NSMutableArray array];
        [keywords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            keyValue *oneKV = [[keyValue alloc]init];
            oneKV.content = partString;
            oneKV.keyword = obj;
            NSString *Pattern = [NSString stringWithFormat:@"(?<=%@=\")\\w+",obj];
            oneKV.expression = [[NSRegularExpression alloc]initWithPattern:Pattern options:0 error:nil];
            oneKV.valueBack = valueBack;
            [keyVs addObject:oneKV];
        }];
        config.keyValues = keyVs;
        result = config;
    }else{
         NSArray<NSString *> *keys = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyword_keyPath_image" ofType:@"plist"]] allKeys];
        ImageMessage *imgMsg = [[ImageMessage alloc]init];
        imgMsg.type = type;
        [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *pattern = [NSString stringWithFormat:@"(?<=%@=\")\\w+",key];
            NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:0 error:nil];
            NSTextCheckingResult *result = [regular firstMatchInString:partString options:0 range:NSMakeRange(0, partString.length)];
            NSString *conRes = [partString substringWithRange:result.range];
            [imgMsg setValue:conRes forKey:key];
        }];
        result = imgMsg;
    }
    return result;
}
/**
 * 从片段中得到将要展示的内容
 *
 *  @param parserShowContentBack
 *
 *  @return
 */
static NSString * parserShowContent(SourceType type,NSString *onePart){
    if (type==textType) {
        //返回对于的文本
        return  [[onePart componentsSeparatedByString:@"<font"] firstObject];
    }else if(type == imageType){
        //返回长度为 1 (空格) 来作为图片的占位符
        return @" ";
    }else{
        return @"";
    }
}
/**
 *  这个方法是根据片段 partConfig对象
 *  各个配置关键字,关键字对于的值,值对应片段的FrameParserConfig 属性的Class
 *  example
 *      <font color="red">
 *--->  ("color","red",UIColor)
 *  @param parserValueCallBack
 *
 *  @return 把关键字的值解析为clazz 具体的值
 */
static id getRealValue(NSString *key,NSString *value,Class clazz){
    //针对 NSNumber UIColor NSString 做出对于的解析
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
}
#endif
