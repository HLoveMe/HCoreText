//
//  UIView+viewExtend.m
//  微博
//
//  Created by lx on 15/9/12.
//  Copyright (c) 2015年 朱子豪. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)
-(CGFloat)x{
    CGRect rect=self.frame;
    return rect.origin.x;
}
-(void)setX:(CGFloat)x{
    CGRect rect=self.frame;
    rect.origin.x=x;
    self.frame=rect;
}
-(CGFloat)y{
    CGRect rect=self.frame;
    return rect.origin.y;
}
-(void)setY:(CGFloat)y{
    CGRect rect=self.frame;
    rect.origin.y=y;
    self.frame=rect;
}
-(CGPoint)origin{
    return self.frame.origin;
}
-(void)setOrigin:(CGPoint)origin{
    CGRect rect=self.frame;
    rect.origin=origin;
    self.frame=rect;
}
-(CGSize)size{
    return self.frame.size;
}
-(void)setSize:(CGSize)size{
    CGRect rect=self.frame;
    rect.size=size;
    self.frame=rect;
}
-(CGFloat)width{
    return self.frame.size.width;
}
-(void)setWidth:(CGFloat)width{
    CGRect rect=self.frame;
    rect.size.width=width;
    self.frame=rect;
}

-(CGFloat)height{
    return  self.frame.size.height;
}

-(void)setHeight:(CGFloat)height{
    CGRect rect=self.frame;
    rect.size.height=height;
    self.frame=rect;
}
-(CGFloat)centerX{
    return self.center.x;
}
-(void)setCenterX:(CGFloat)centerX{
    CGPoint cen=self.center;
    cen.x=centerX;
    self.center=cen;
}
-(CGFloat)centerY{
    return self.center.y;
}
-(void)setCenterY:(CGFloat)centerY{
    CGPoint cen=self.center;
    cen.y=centerY;
    self.center=cen;
}
-(CGFloat)MaxX{
    return CGRectGetMaxX(self.frame);
}
-(CGFloat)MaxY{
    return CGRectGetMaxY(self.frame);
}
@end
