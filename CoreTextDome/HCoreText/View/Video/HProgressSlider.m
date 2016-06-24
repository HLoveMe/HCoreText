//
//  HProgressSlider.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "HProgressSlider.h"
@interface HProgressSlider()
@property(nonatomic,strong)CAShapeLayer *shape;
@end
@implementation HProgressSlider
-(CAShapeLayer *)shape{
    if (_shape==nil) {
        _shape=[[CAShapeLayer alloc]init];
        _shape.fillColor=[[UIColor whiteColor] colorWithAlphaComponent:0.75].CGColor;
        _shape.lineCap=kCALineCapRound;
    }
    return _shape;
}
-(void)setCacheProgress:(double)cacheProgress{
    _cacheProgress=cacheProgress;
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat wid = self.frame.size.width;
    CGFloat thisWid = (_cacheProgress-self.value)*wid+self.subviews.lastObject.frame.size.width/2;
    CGFloat thisHei=2;
    UIBezierPath *path= [UIBezierPath bezierPathWithRect:CGRectMake(0, 0,thisWid, thisHei)];
    self.shape.path=path.CGPath;
    UIView *one = self.subviews.firstObject;
    [one.layer addSublayer:self.shape];
}
@end
