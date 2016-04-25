//
//  CoretextData.h
//  CoreQuart2D_00
//
//  Created by 朱子豪 on 16/4/20.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class FrameParserConfig;
@interface CoretextData : NSObject
@property(nonatomic,readonly)BOOL isAutoAdjustHeight;
@property(nonatomic,assign)CGFloat realContentHeight;
@property(nonatomic,assign)CTFrameRef frameRef;
@end
