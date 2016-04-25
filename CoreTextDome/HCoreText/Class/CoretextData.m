//
//  CoretextData.m
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "CoretextData.h"
#import "FrameParserConfig.h"

@interface CoretextData()

@end
@implementation CoretextData

-(void)setFrameRef:(CTFrameRef)frameRef{
    if (_frameRef!=frameRef) {
        if (_frameRef != nil) {
            CFRelease(_frameRef);
        }
        CFRetain(frameRef);
        _frameRef = frameRef;
    }
}
-(void)dealloc{
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = NULL;
    }
}

@end
