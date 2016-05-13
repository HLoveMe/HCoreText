//
//  CoreTextData.m
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "CoreTextData.h"
#import "FrameParserConfig.h"
#import "partMessage.h"
#import "FontConfig.h"
@interface CoreTextData()

@end
@implementation CoreTextData
-(NSMutableArray<Message *> *)msgArray{
    if (!_msgArray) {
        _msgArray= [NSMutableArray array];
    }
    return _msgArray;
}
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
