//
//  HvideoPlayView.h
//
//  Created by lx on 15/10/24.
//  Copyright (c) 2015年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class HVideoPlayView;;
@protocol HVideoPlayerDelegate <NSObject>
@optional
/**
 *  错误
 *
 *  @param error
 */
-(void)videoPlayerDidError:(NSError *)error;
/**
 *  开始播放
 *
 *  @param playerView
 */
-(void)videoPlayerDidBeginPlay:(HVideoPlayView *)playerView;
/**
 *  播放结束
 *
 *  @param playerView
 */
-(void)videoPlayerDidFinish:(HVideoPlayView *)playerView;
/**播放进度*/
-(void)videoPlayer:(HVideoPlayView *)playerView  withPlayProgress:(double)progress;
/**缓存进度*/
-(void)videoPlayer:(HVideoPlayView *)playerView  withCacheProgress:(double)progress;
@end


@interface HVideoPlayView : UIButton
@property(nonatomic,weak)id<HVideoPlayerDelegate> delegate;
/**
 *  缓冲结束
 */
@property(nonatomic,assign,readonly)BOOL bufferEnd;
//是否已经开始播放
@property(nonatomic,assign,readonly)BOOL isPlayed;
//是否正在播放
-(BOOL)isPlaying;
/**
 *  播放
 */
-(void)play;
/**
 * 切换视频源
 */
-(void)switchUseURL:(NSURL *)url;
 /**暂停*/
-(void)pause;
 /**恢复*/
-(void)resume;
 /**当前时间点*/
-(double)currentTime;
//缓存进度
-(double)cachaProgress;
 /**视频长度*/
-(double)duration;
 /**移动到时间点 */
-(void)seekToTime:(double)time;
 /**移动到某个时间点 0---->! */
 /**
  NSDate *date = [[NSDate alloc]initWithTimeInterval:position sinceDate:开始播放的时间点];
  */
-(void)seeKToDate:(NSDate*)date;


-(instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url;

@end

