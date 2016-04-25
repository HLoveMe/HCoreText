//
//  UIView+viewExtend.h
//  微博
//
//  Created by lx on 15/9/12.
//  Copyright (c) 2015年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGPoint origin;
@property(nonatomic,assign)CGSize size;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,assign)CGFloat centerX;
@property(nonatomic,assign)CGFloat centerY;
@property(nonatomic,readonly)CGFloat MaxX;
@property(nonatomic,readonly)CGFloat MaxY;
@end
