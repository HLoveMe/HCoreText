//
//  CTDrawView.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/4.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CoreTextData;
@protocol CTViewTouchDelegate<NSObject>
@optional
/**
 *  点击事件开启之后才会生效 针对文字内容
 *
 *  @param view    当前视图
 *  @param range   点击文本的范文
 *  @param content 点击的文本
 */
-(void)touchView:(UIView *)view contentRange:(NSRange)range contentString:(NSString *)content attributes:(NSMutableDictionary*)attribute;
/**
 *  点击事件开启后才会生效 针对图片 通过HImageBox得到对于图片
 *
 *  @param view   当前视图
 *  @param range  图片占位位置范围
 *  @param source 图片名 或者网址
 */
-(void)touchView:(UIView *)view contentRange:(NSRange)range imageName:(NSString *)source;
@end

@interface CTDrawView : UIView
/**
 *  是否接受点击事件 default YES
 *  只是针对使用CoreText绘制内容UIView 监控点击内容的Touch事件
 */
@property(nonatomic,assign)BOOL beginTouchEvent;
/**
 *  点击事件代理
 */
@property(nonatomic,weak)id<CTViewTouchDelegate> delegate;
/**
 *  文本绘制
 *
 *  @param data CoreTextData解析对象
 */
-(void)drawWithCoreTextData:(CoreTextData *)data;
@end
