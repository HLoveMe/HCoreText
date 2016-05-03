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
 *  删除过时文件  1周
 */
+(void)removeTimeOutFile;
/**
 *  删除所有本地文件
 */
+(void)removeAllFile;
/**
 *  获取图片
 *
 *  @param src   图片名或者图片网址
 *  @param block   得到图片主线程回调 
 *  img  得到的图片 可能为nil isFirst获取网络图片回调会出现绘制不正确 尝试刷新重新绘制
 */
+(void)getImageWithSource:(NSString *)src option:(void(^)(UIImage *img,BOOL isFirst))block;
@end
