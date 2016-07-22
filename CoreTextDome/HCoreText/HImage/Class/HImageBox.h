//
//  HImageBox.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/3.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HImageBox : NSObject
/**
 *  删除过时文件  1周 内部自动会调用
 */
+(void)removeTimeOutFile;
/**
 *  删除所有本地文件
 */
+(void)removeAllFile;
/**
 *  获取图片  本地有该图片就是同步执行 需要网络请求 Block在得到图片后 main线程执行
 *
 *  @param src   图片名或者图片网址
 *  @param block   得到图片主线程回调 
 *  img  得到的图片 可能为nil isFirst获取网络图片回调会出现绘制不正确 尝试刷新重新绘制
 */
+(void)getImageWithSource:(NSString *)src option:(void(^)(UIImage *img,BOOL isFirst))block;
/**
 *  得到指定视频源的帧
 *
 *  @param url
 *  @param time 第几帧
 *  @param option 回调 
 */
+(void)getFrameImageWithURL:(NSURL *)url atTime:(double)time option:(void(^)(UIImage *img))option;
@end
