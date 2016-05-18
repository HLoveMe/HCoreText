//
//  FrameParserDelegate.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/11.
//  Copyright © 2016年 朱子豪. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class  Message;
#import "ParserType.h"
@protocol FrameParserDelegate<NSObject>
@required
/**
 *  把带有参数信息文本 按照文字，图片 等分割为不同的部分
 *
 *  @param conent 参数信息文本
 *
 *  @return 分割出来字符串数组
 */
-(NSMutableArray<NSString *>*)parserWithContent:(NSString *)conent;
/**
 *  返回该文本信息 需要解析的关键字数组
 *
 *  @param partText 块文本
 *
 *  @return 关键字参数
 */
-(NSArray <NSString *>*)parserKeywordWithPartText:(NSString *)partText type:(SourceType)type;
/**
 *  通过关键字等信息解析文本内容
 *
 *  @param partText 部分文本内容
 *
 *  @return Message 的子类
 */
-(Message *)parserMessageWithPartText:(NSString *)partText;

@optional
/**
 *  通过文本内容得到该部分是文字 还是图片
 *  Note：如果没有实现 判断的准则就是是否包含“<text”字段 包含则是Text 否则为image
          如果你的文本解析出现混乱 或者判断条件不是该字段 请实现该方法
 *  @param partText 部分文本
 *
 *  @return SourceType
 */
-(SourceType)parserTypeWithPart:(NSString *)partText;
/**
 *  得到部分文本的具体显示内容
 *  Note:如果没有实现 默认得到"<text" 前面的文本。如果是图片会返回长度为1 的占位文本
 *       如果你的文本解析出现混乱 或者判断条件不是该字段 请实现该方法
 *
 *  @param type    文本类型
 *  @param onePart 部分文本
 *
 *  @return 具体显示的类型
 */
-(NSString *)parserShowText:(SourceType)type text:(NSString *)onePart;
@end
