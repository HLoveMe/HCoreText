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
 *  @param sources 当前内容中所有的文本
 */
-(void)touchView:(UIView *)view  imageName:(NSString *)source contentSources:(NSArray *)sources;
/**
 *  视频点击事件
 *
 *  @param view
 *  @param play
 *  @param source   
 *  该事件可能不会被调用   当你所提供的播放视图 接收到点击事件并处理      而不是被CTDrawView接受
 */
-(void)touchView:(UIView *)view  videoSource:(NSString *)source;
/**
 *  当你需要进行视频播放时 你实现这个方法 返回你的播放器
 *  如果你没有实现将使用默认播放器 该播放器只是提供播放功能
 *  @param source 视频源
 *  1：返回值:只能是三种情况: CALayer 子类  UIView子类   UIViewController子类
        并且播放功能(暂停 继续 进度显示 等等) and  触摸事件必须你自己处理
 *  2：如果类型会报错
 *  @return
 */
-(id)drawViewWillShowVideo:(NSString *)source;

@end

@interface CTDrawView : UIView
/**
 *  是否接受点击事件 default YES
 *  只是针对使用CoreText绘制内容UIView 监控点击内容的Touch事件
 */
@property(nonatomic,assign)BOOL beginTouchEvent;
/**
 *   代理事件
 */
@property(nonatomic,weak)id<CTViewTouchDelegate> delegate;
/**
 *  文本绘制
 *
 *  @param data CoreTextData解析对象
 */
-(void)drawWithCoreTextData:(CoreTextData *)data;

@end
