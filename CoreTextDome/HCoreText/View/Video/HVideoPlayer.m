//
//  HVideoPlayer.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "HVideoPlayer.h"

@implementation HVideoPlayer
static HVideoPlayer * single;
+(instancetype)sharedPlayer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single=[[self alloc]init];
        AVPlayer *layer =[[AVPlayer alloc]init];
        single.player=layer;
    });
    return single;
}
@end

@implementation HVideoItem

-(void)dealloc{
    
}
@end
