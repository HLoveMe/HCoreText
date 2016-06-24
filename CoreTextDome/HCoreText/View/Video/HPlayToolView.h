//
//  HPlayToolView.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/22.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class HPlayToolView;
@protocol HPlayViewDelegate<NSObject>
@optional
-(BOOL)toolView:(HPlayToolView *)view play:(BOOL)flag;

-(void)toolView:(HPlayToolView *)view changeProgress:(double)time;

-(void)toolViewToScreen:(HPlayToolView *)view;
@end

@interface HPlayToolView : UIView
@property(nonatomic,weak)AVPlayer *player;
@property(nonatomic,weak)id<HPlayViewDelegate> delegate;
@property(nonatomic,assign,readonly)BOOL isCaching;
-(void)initStatus;
-(void)showPreperPlay;
-(void)showFinishPlay;
//缓存期间 不能接受点击事件 直到调用endCache
//-(void)showCache;
//-(void)endCache;
-(void)showError;
-(void)networkError;
@end
