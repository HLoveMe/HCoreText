//
//  CTDrawView.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/4.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "CTDrawView.h"
//#import <objc/runtime.h>
#import "partMessage.h"
#import "HImageBox.h"
#import "CoreTextData.h"
#import "UIView+Extension.h"
#import "FontConfig.h"
#import "HVideoPlayView.h"

#import "FrameParserConfig.h"

@interface CTDrawView()
@property(nonatomic,strong)NSMutableArray *coreDatas;
@end
@implementation CTDrawView{
    UIColor *hightColor;
    NSMutableArray *hightRectArray;
    NSMutableDictionary *videoViews;
    
}
-(NSMutableArray *)coreDatas{
    if (nil==_coreDatas) {
        _coreDatas=[NSMutableArray array];
    }
    return _coreDatas;
}
-(void)initSource{
    self.beginTouchEvent = 1;
    videoViews=[NSMutableDictionary dictionary];
}

-(instancetype)init{
    if ([super init]) {
        [self initSource];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self initSource];
    }
    return self;
}
-(void)drawWithCoreTextData:(CoreTextData *)data{
    self.frame  = CGRectMake(self.x, self.y, self.width,data.isAutoAdjustHeight?data.realContentHeight:self.height);
    [self setNeedsLayout];
    [self.coreDatas addObject:data];
    [self setNeedsDisplay];
}
-(void)appendCoreTextData:(CoreTextData *)data{
    __block CGFloat hei;
    [self.coreDatas enumerateObjectsUsingBlock:^(CoreTextData *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        hei+=obj.realContentHeight;
    }];
    self.frame  = CGRectMake(self.x, self.y, self.width,data.isAutoAdjustHeight?hei+data.realContentHeight:self.height);
    [self setNeedsLayout];
    [self.coreDatas addObject:data];
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect{
    CGContextRef ref=UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);
    CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
    NSLog(@"%f",self.bounds.size.height);
    CGContextTranslateCTM(ref, 0, self.bounds.size.height);
    CGContextScaleCTM(ref, 1, -1);
    
    
    NSArray<CoreTextData *> *datas = self.coreDatas;
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
            NSString *showStr = msg.attSring.string;
            if(msg.type == ImageType|msg.type==VideoType) {
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
                            //                            CTRunGetPositionsPtr(CTRunRef  _Nonnull run)
                            //line 的起点位置  x
                            CGFloat lineXOffset = origins[i].x;
                            // line y
                            CGFloat lineY = origins[i].y;
                            
                            CGRect imgRect = CGRectMake(lineXOffset+runXOffset, lineY, wid, ascent);
                            if (imgMsg.isCenter) {
                                CGFloat x =(self.frame.size.width-wid)/2;
                                imgRect=CGRectMake(x, lineY, wid, ascent);
                            }
                            imgMsg.rect=imgRect;
                            //图片
                            if([msg isMemberOfClass:[ImageMessage class]]){
                                [HImageBox getImageWithSource:imgMsg.src option:^(UIImage *img,BOOL isFirst) {
                                    if (isFirst) {
                                        [self setNeedsDisplay];
                                    }else{
                                        CGContextDrawImage(ref, imgRect,img.CGImage);
                                    }
                                }];
                            }else{
                                //视频
                                VideoMessage *video =(VideoMessage *)msg;
                                if (video.hasShow) {
                                    return;
                                }
                                CGFloat Y = self.frame.size.height-ascent-lineY;
                                CGRect rect = CGRectMake(imgRect.origin.x, Y, wid, ascent);
                                /**
                                 *  <#Description#>
                                 */
                                id videoView;
                                if ([self.delegate respondsToSelector:@selector(drawViewWillShowVideo:)]) {
                                    videoView = [self.delegate drawViewWillShowVideo:video.src];
                                }else{
                                    videoView=[[HVideoPlayView alloc]init];
                                    [videoView switchUseURL:[NSURL URLWithString:video.src]];
                                }
                                if ([videoView isKindOfClass:[UIViewController class]]) {
                                    videoView =((UIViewController *)videoView).view;
                                }
                                [videoView setValue:[NSValue valueWithCGRect:rect] forKey:@"frame"];
                                [self addSubview:videoView];
                                videoViews[video.src]=videoView;
                                video.hasShow=YES;
                            }
                        }
                    }
                }
                
            }
            location += showStr.length;
        }
    }
    CGContextRestoreGState(ref);
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.coreDatas.count==0) {return;}
    if (!self.beginTouchEvent) {return;}
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGPoint touchPoint = CGPointMake(point.x, self.height-point.y);
    [self.coreDatas enumerateObjectsUsingBlock:^(CoreTextData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
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
                    //判断是否为图片/视频
                    CFRange range = CTRunGetStringRange(CFArrayGetValueAtIndex(runs, j));
                    NSString *string = [data.contentString.string substringWithRange:NSMakeRange(range.location, range.length)];
                    if ([string isEqualToString:@" "]) {
                        for (int k=0; k<data.msgArray.count; k++) {
                            Message * _Nonnull msg=data.msgArray[k];
                            if ([msg isKindOfClass:[ImageMessage class]]) {
                                if (CGRectContainsPoint([(ImageMessage*)msg rect], touchPoint)) {
                                    [self transferDelegate:msg coreData:data];
                                    return ;
                                }
                            }
                        }
                    }
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    const CGPoint *point = CTRunGetPositionsPtr(run);
                    CGFloat ascent;
                    CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, nil, nil);
                    
                    CGRect rect = CGRectMake(point->x, point->y+hei, width, ascent);
                    if( CGRectContainsPoint(rect, touchPoint)){
                        CFRange runRange = CTRunGetStringRange(run);
                        [data.msgArray enumerateObjectsUsingBlock:^(Message * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop2) {
                            if (![msg isKindOfClass:[ImageMessage class]]) {
                                long msgEnd = msg.contentRange.location+msg.contentRange.length;
                                long runEnd = runRange.location+runRange.length;
                                if (msg.contentRange.location<=runRange.location&&msgEnd>=runEnd) {
                                    if (self.delegate) {
                                        [self transferDelegate:msg coreData:data];
                                        return ;
                                    }
                                    *stop2 = YES;
                                }
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
-(void)transferDelegate:(Message *)msg coreData:(CoreTextData *)core{
    if (msg.type == TextType) {
        if ([self.delegate respondsToSelector:@selector(touchView:contentString:)]) {
            [self.delegate touchView:self contentString:msg.attSring.string];
        }
        
    }else if(msg.type == ImageType) {
        if( [self.delegate respondsToSelector:@selector(touchView:imageName:contentSources:)]){
//            NSMutableArray *all = [NSMutableArray array];
            NSMutableArray *current = [NSMutableArray array];
            [self.coreDatas enumerateObjectsUsingBlock:^(CoreTextData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [obj.msgArray enumerateObjectsUsingBlock:^(Message * _Nonnull one, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([one isMemberOfClass:[ImageMessage class]]){
                        ImageMessage *img = (ImageMessage *)one;
                        if (obj==core){
                            [current addObject:img.src];
                        }
//                        [all addObject:img.src];
                    }
                }];
                
            }];
            
            [self.delegate touchView:self imageName:[(ImageMessage*)msg src]contentSources:current];
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
    }else if (msg.type==VideoType){
        VideoMessage *video=(VideoMessage *)msg;
        if([self.delegate respondsToSelector:@selector(touchView:videoSource:)]){
            [self.delegate touchView:self videoSource:video.src];
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
    [self.coreDatas enumerateObjectsUsingBlock:^(CoreTextData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
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

@end
