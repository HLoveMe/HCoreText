//
//  CTDrawView.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/4.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "CTDrawView.h"
#import <objc/runtime.h>
#import "partMessage.h"
#import "HImageBox.h"
#import "CoreTextData.h"
#import "UIView+Extension.h"
@implementation CTDrawView
-(instancetype)init{
    if (self = [super init]) {
        self.beginTouchEvent = 1;
    }
    return self;
}

-(void)drawWithCoreTextData:(CoreTextData *)data{
    self.frame  = CGRectMake(self.x, self.y, self.width,data.isAutoAdjustHeight?data.realContentHeight:self.height);
    [self setNeedsLayout];
    objc_setAssociatedObject(self, "coreDatas", @[data], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef ref=UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
    CGContextTranslateCTM(ref, 0, self.bounds.size.height);
    CGContextScaleCTM(ref, 1, -1);
    NSArray<CoreTextData *> *datas = objc_getAssociatedObject(self, "coreDatas");
    for (CoreTextData * obj in datas) {
        //画所有文字
        CTFrameDraw(obj.frameRef, ref);
        //画图片
        __block long location = 0;
        CFArrayRef lineRef = CTFrameGetLines(obj.frameRef);
        long count = CFArrayGetCount(lineRef);
        CGPoint origins[count];
        CTFrameGetLineOrigins(obj.frameRef, CFRangeMake(0, 0), origins);
        for (Message * _Nonnull msg in obj.msgArray) {
            if (msg.type == textType){
                NSString *showStr = msg.showContent;
                location += showStr.length;
            } else if (msg.type == imageType) {
                ImageMessage *imgMsg = (ImageMessage *)msg;
                for (long i=0; i<count; i++) { //遍历行
                    CTLineRef oneLine= CFArrayGetValueAtIndex(lineRef, i);
                    CFArrayRef runs = CTLineGetGlyphRuns(oneLine);
                    long num = CFArrayGetCount(runs);
                    for (long j=0; j<num; j++) { //遍历  line  runs
                        CTRunRef run= CFArrayGetValueAtIndex(runs, j);
                        CFRange range = CTRunGetStringRange(run);
                        //判断图片占位信息
                        if (range.location<=location&&(range.location + range.length)>location) {
                            //得到该run的信息
                            CGFloat ascent;
                            CGFloat descent;
                            CGFloat wid = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil);
                            //run相对于line的x偏移量
                            CGFloat runXOffset = CTLineGetOffsetForStringIndex(oneLine, range.location, nil);
                            //                            CTRunGetPositionsPtr(<#CTRunRef  _Nonnull run#>)
                            //line 的起点位置  x
                            CGFloat lineXOffset = origins[i].x;
                            // line y
                            CGFloat lineY = origins[i].y;
                            
                            CGRect imgRect = CGRectMake(lineXOffset+runXOffset, lineY, wid, ascent);
                            //                            UIImage *img =  [UIImage imageNamed:imgMsg.src];
                            //                            CGContextDrawImage(ref, imgRect,img.CGImage);
                            [HImageBox getImageWithSource:imgMsg.src option:^(UIImage *img,BOOL isFirst) {
                                if (isFirst) {
                                    [self setNeedsDisplay];
                                }else{
                                    CGContextDrawImage(ref, imgRect,img.CGImage);
                                }
                            }];
                        }
                    }
                }
            }
            
        }
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    id coreD = objc_getAssociatedObject(self, "coreDatas");
    if (!coreD) {return;}
    if (!self.beginTouchEvent) {return;}
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSArray<CoreTextData *> *cores = coreD;
    CGPoint touchPoint = CGPointMake(point.x, self.height-point.y);
    [cores enumerateObjectsUsingBlock:^(CoreTextData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        CFArrayRef lines = CTFrameGetLines(data.frameRef);
        int count = (int)CFArrayGetCount(lines);
        CGPoint points[count];
        CTFrameGetLineOrigins(data.frameRef, CFRangeMake(0, 0), points);
        for (int i=0; i<count; i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CGFloat hei = points[i].y;
            BOOL flag=0;
            if (hei<touchPoint.y) {
                for (int j=0; j<CFArrayGetCount(runs); j++) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    const CGPoint *point = CTRunGetPositionsPtr(run);
                    CGFloat ascent;
                    CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, nil, nil);
                    CGRect rect = CGRectMake(point->x, point->y+hei, width, ascent);
                    if( CGRectContainsPoint(rect, touchPoint)){
                        CFRange runRange = CTRunGetStringRange(run);
                        [data.msgArray enumerateObjectsUsingBlock:^(Message * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop2) {
                            long msgEnd = msg.contentRange.location+msg.contentRange.length;
                            long runEnd = runRange.location+runRange.length;
                            if (msg.contentRange.location<=runRange.location&&msgEnd>=runEnd) {
                                if (self.delegate) {
                                    if (msg.type == textType) {
                                        if ([self.delegate respondsToSelector:@selector(touchView:contentRange:contentString:attributes:)]) {
                                           [self.delegate touchView:self contentRange:msg.contentRange contentString:msg.showContent attributes:[msg attributeDic]];
                                        }
                                        
                                    }else {
                                        [self.delegate touchView:self contentRange:msg.contentRange imageName:[(ImageMessage*)msg src]];
                                    }
                                }
                                *stop2 = YES;
                            }
                        }];
                        flag=1;
                        *stop = YES;
                        break;
                    }
                }
            }
            if (flag) {break;}
            
        }
    }];
}
-(void)dealloc{
    objc_removeAssociatedObjects(self);
}
@end
