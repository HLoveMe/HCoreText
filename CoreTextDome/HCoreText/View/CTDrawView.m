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
#import "FontConfig.h"
@interface CTDrawView()
@property(nonatomic,strong)Message *tempMsg;
@property(nonatomic,strong)FontConfig *tempFont;
@end
@implementation CTDrawView{
    UIColor *hightColor;
    NSMutableArray *hightRectArray;
}
-(instancetype)init{
    if ([super init]) {
        self.beginTouchEvent = 1;
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
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
    if (hightColor&&hightRectArray) {
        [hightColor set];
        [hightRectArray enumerateObjectsUsingBlock:^(NSValue *rectValue, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [rectValue CGRectValue];
            
            CGPathRef pathRef = [self getRoundRect:rect];
            CGContextAddPath(ref, pathRef);
            CGContextFillPath(ref);
        }];
    }
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
            if (msg.type == TextType||msg.type==LinkType){
                NSString *showStr = msg.attSring.string;
                location += showStr.length;
            } else if (msg.type == ImageType) {
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
                                    [self transferDelegate:msg];
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
-(void)transferDelegate:(Message *)msg{
    if (msg.type == TextType) {
        if ([self.delegate respondsToSelector:@selector(touchView:contentString:)]) {
            [self.delegate touchView:self contentString:msg.attSring.string];
        }
        
    }else if(msg.type == ImageType) {
        if( [self.delegate respondsToSelector:@selector(touchView:imageName:)]){
            [self.delegate touchView:self imageName:[(ImageMessage*)msg src]];
        }
    }else if (msg.type==LinkType){
        if ([self.delegate respondsToSelector:@selector(touchView:contentString:URLString:)]) {
            TextLinkMessage *link = (TextLinkMessage *)msg;
            UIColor *cfg = [self.delegate touchView:self contentString:link.attSring.string URLString:link.URLSrc];
            if (cfg) {
                hightColor = cfg;
                hightRectArray = [self getTouchFrameCurrentMsg:(TextMessage *)msg];
                [self setNeedsDisplay];
            }
        }
        
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    hightRectArray=nil;
    hightColor = nil;
    [self setNeedsDisplay];

}
/**
 *  得到所有应该高亮的rect 数组
 *
 *  @param msg <#msg description#>
 *
 *  @return <#return value description#>
 */
-(NSMutableArray *)getTouchFrameCurrentMsg:(TextMessage *)msg{
    NSMutableArray *rectArray = [NSMutableArray array];
    NSArray<CoreTextData *> *datas = objc_getAssociatedObject(self, "coreDatas");
    [datas enumerateObjectsUsingBlock:^(CoreTextData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        CFArrayRef lines = CTFrameGetLines(data.frameRef);
        int count =(int)CFArrayGetCount(lines);
        CGPoint points[count];
        CTFrameGetLineOrigins(data.frameRef, CFRangeMake(0, 0), points);
        for (int i=0; i<count; i++) {//遍历行
            CTLineRef oneLine = CFArrayGetValueAtIndex(lines, i);
            CFArrayRef runs = CTLineGetGlyphRuns(oneLine);
            int runCount = (int)CFArrayGetCount(runs);
            NSMutableArray *runFrams = [NSMutableArray array];
            for (int j=0; j<runCount; j++) {
                CTRunRef oneRun = CFArrayGetValueAtIndex(runs, j);
                CFRange runRange = CTRunGetStringRange(oneRun);
                long msgEnd = msg.contentRange.location+msg.contentRange.length;
                long runEnd = runRange.location+runRange.length;
                
                if (runRange.location>=msg.contentRange.location&&msgEnd>=runEnd) {
                    const CGPoint *position = CTRunGetPositionsPtr(oneRun);
                    CGFloat ascent;
                    CGFloat width = CTRunGetTypographicBounds(oneRun, CFRangeMake(0, 0), &ascent, nil, nil)+2;
                    ascent+=msg.fontCig.fontSize * 0.25;
                    CGPoint lineOrigin = points[i];
                    CGFloat runX = lineOrigin.x + position->x;
                    CGFloat runY = lineOrigin.y-msg.fontCig.fontSize * 0.3;
                    CGRect rect = CGRectMake(runX, runY, width, ascent);
                    
                    NSValue *oneValue = [NSValue value:&rect withObjCType:@encode(CGRect)];
                    //得到Line 所有应该高亮的Run  rect
                    [runFrams addObject:oneValue];
                }
            }
            if (runFrams.count>=1) {
                CGFloat x = [runFrams.firstObject CGRectValue].origin.x;
                CGFloat wid = CGRectGetMaxX([runFrams.lastObject CGRectValue])-x;
                __block CGFloat hei;
                [runFrams enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL * _Nonnull stop) {
                    CGRect rect = [value CGRectValue];
                    if (rect.size.height>hei) {
                        hei=rect.size.height;
                    }
                }];
                CGFloat y =[runFrams.firstObject CGRectValue].origin.y;
                //得到  Line  所有Run 连起来的Rect
                CGFloat temp = msg.fontCig.fontSize * 0.1>2?msg.fontCig.fontSize * 0.1:2;
                CGRect lineRunRect = CGRectMake(x, y, wid-temp, hei);
//                NSLog(@"%@",NSStringFromCGRect(lineRunRect));
                [rectArray addObject:[NSValue valueWithCGRect:lineRunRect]];
            }
        }
    }];
    return rectArray;
}
-(CGPathRef)getRoundRect:(CGRect)rect{
    UIBezierPath *beziPath = [UIBezierPath bezierPath];
    CGPoint origin = rect.origin;
    CGSize size = rect.size;
    CGFloat radius=5;
    [beziPath moveToPoint:CGPointMake(origin.x+radius,origin.y)];
    [beziPath addLineToPoint:CGPointMake(origin.x+size.width-radius, origin.y)];
    [beziPath addArcWithCenter:CGPointMake(origin.x+size.width-radius, origin.y+radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    
    [beziPath addLineToPoint:CGPointMake(origin.x+size.width, origin.y+size.height-radius)];

    [beziPath addArcWithCenter:CGPointMake(origin.x+size.width-radius, origin.y+size.height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    [beziPath addLineToPoint:CGPointMake(origin.x+radius, origin.y+size.height)];

    [beziPath addArcWithCenter:CGPointMake(origin.x+radius, origin.y+size.height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [beziPath addLineToPoint:CGPointMake(origin.x, origin.y+radius)];

    
    [beziPath addArcWithCenter:CGPointMake(origin.x+radius, origin.y+radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    
    return beziPath.CGPath;
}


-(void)dealloc{
    objc_removeAssociatedObjects(self);
}
@end
