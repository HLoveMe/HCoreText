//
//  CTDrawView.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/4.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CoreTextData;
@class FontConfig;
@protocol CTViewTouchDelegate<NSObject>
@optional
/**
 *  点击事件开启之后才会生效 针对文字内容
 *
 *  @param view    当前视图
 *  @param content 点击的文本
 *
 */
-(void)touchView:(UIView *)view  contentString:(NSString *)content;
/**
 *  点击事件开启之后才会生效 针对Link文本
 *
 *  @param view      当前视图
 *  @param content   显示的文字
 *  @param urlString url
 *
 *  @return 点击之后URL文本应该显示的文本背景颜色 nil无响应
 */
-(UIColor *)touchView:(UIView *)view contentString:(NSString *)content URLString:(NSString *)urlString ;
/**
 *  点击事件开启后才会生效 针对图片 通过HImageBox得到对于图片
 *
 *  @param view   当前视图
 *  @param source 图片名 或者网址
 */
-(void)touchView:(UIView *)view  imageName:(NSString *)source;
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
