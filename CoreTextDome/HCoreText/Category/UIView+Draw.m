//
//  UIView+Draw.m
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "UIView+Draw.h"
#import <objc/runtime.h>
@implementation UIView (Draw)
+(void)load{
     Method one = class_getInstanceMethod([self class], @selector(drawRect:));
     Method two = class_getInstanceMethod([self class], @selector(_drawRect:));
     method_exchangeImplementations(one, two);
}
-(void)_drawRect:(CGRect)rect{
    CGContextRef ref=UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
    CGContextTranslateCTM(ref, 0, self.bounds.size.height);
    CGContextScaleCTM(ref, 1, -1);
    NSArray<CoretextData *> *datas = objc_getAssociatedObject(self, "coreDatas");
    [datas enumerateObjectsUsingBlock:^(CoretextData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CTFrameDraw(obj.frameRef, ref);
    }];
    [self _drawRect:rect];
}

-(void)drawWithCoretextData:(CoretextData *)data{
    NSAssert([self isKindOfClass:[UIView class]], @"自定义View 并实现drawRect:");
    self.frame  = CGRectMake(self.x, self.y, self.width,data.isAutoAdjustHeight?data.realContentHeight:self.height);
    [self setNeedsLayout];
    objc_setAssociatedObject(self, "coreDatas", @[data], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _drawRect:self.bounds];
}
-(void)dealloc{
    objc_removeAssociatedObjects(self);
}
@end
