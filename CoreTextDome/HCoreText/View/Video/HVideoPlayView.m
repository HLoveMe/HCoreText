//
//  HvideoPlayView.m
//
//  Created by lx on 15/10/24.
//  Copyright (c) 2015年 朱子豪. All rights reserved.
//

#import "HVideoPlayView.h"
#import "UIView+Display.h"
#import "HPlayToolView.h"
#import "HImageBox.h"
#import "HVideoPlayer.h"
@interface HVideoPlayView()<HPlayViewDelegate>{
    BOOL isRegistered;
}
@property(nonatomic,strong)AVPlayerLayer *HPlayerLayer;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,weak)AVPlayer *HPlayer;
@property(nonatomic,assign)double currentVeidoDuration;
@property(nonatomic,strong)HPlayToolView *toolView;

@property(nonatomic,assign)BOOL _isPlayed;
@property(nonatomic,assign)double _cacheProgress;
@end

@implementation HVideoPlayView
-(BOOL)isPlayed{
    return self._isPlayed;
}
-(AVPlayerLayer *)HPlayerLayer{
    _HPlayerLayer = [HVideoPlayer sharedPlayer];
    _HPlayerLayer.frame=self.bounds;
    _HPlayer=_HPlayerLayer.player;
    self.toolView.player=_HPlayer;
    return _HPlayerLayer;
}
-(HPlayToolView *)toolView{
    if (_toolView==nil) {
        _toolView=[[HPlayToolView alloc]initWithFrame:self.bounds];
        _toolView.delegate=self;
    }
    return _toolView;
}
-(void)setUrl:(NSURL *)url{
    _url=url;
    [self HPlayerLayer];
    [self addSubview:self.toolView];
    [HImageBox getFrameImageWithURL:url atTime:1 option:^(UIImage *img) {
        [self setBackgroundImage:img forState:UIControlStateNormal];
    }];
}

-(instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url{
    if (self=[super initWithFrame:frame]) {
        self.frame=frame;
        self.url=url;
    }
    return self;
}

/**增加监听*/
-(void)addObserverFromItem:(AVPlayerItem *)item{
    HVideoItem *temp = (HVideoItem *)item;
    if (temp.isRegistered)
        return;
    __weak typeof(self) this=self;
    /**status 监听播放转态  为AVPlayerItemStatusReadyToPlay  就可获取视频时长邓信息*/
    [item addObserver:this forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    /**loadedTimeRanges 获取视频  本地 网络 缓存状态*/
    // NSValues containing CMTimeRanges.
    [item addObserver:this forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:this forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
    temp.observer=this;
    
    [[NSNotificationCenter defaultCenter] addObserver:this selector:@selector(videoPlayDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:this.HPlayer.currentItem];
    
    [this.HPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ([this.delegate respondsToSelector:@selector(videoPlayer:withPlayProgress:)]) {
            float current=CMTimeGetSeconds(time);
            this.currentVeidoDuration=CMTimeGetSeconds([this.HPlayer.currentItem duration]);
            if ((current/this.currentVeidoDuration)>=0.0&&(current/this.currentVeidoDuration)<=1.0) {
                [this.delegate videoPlayer:this withPlayProgress:(current/this.currentVeidoDuration)];
            }
        }
    }];
    temp.isRegistered=YES;
}
/**移除监听*/
-(void)removeObserverFromItem:(AVPlayerItem *)item{
    HVideoItem *temp = (HVideoItem *)item;
    if (temp.isRegistered) {
        [item removeObserver:temp.observer forKeyPath:@"status"];
        [item removeObserver:temp.observer forKeyPath:@"loadedTimeRanges"];
        [item removeObserver:temp.observer forKeyPath:@"error"];
        [[NSNotificationCenter defaultCenter] removeObserver:temp.observer];
        
        //playView 恢复初始状态
        [temp.observer.toolView initStatus];
    }
    temp.isRegistered=NO;
//    temp->isPlayed=NO;
}

/**播放完成调用*/
-(void)videoPlayDidFinish:(NSNotification *)notifcation{
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidFinish:)]) {
        [self.delegate videoPlayerDidFinish:self];
    }
    [self.toolView showFinishPlay];
}


/**kvo调用*/
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            _currentVeidoDuration=CMTimeGetSeconds(playerItem.duration);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        if ([self.delegate respondsToSelector:@selector(videoPlayer:withCacheProgress:)]) {
            double  progress=totalBuffer/_currentVeidoDuration;
            if(1.0>=progress&&progress>=0.0)
                self._cacheProgress=progress;
                [self.delegate videoPlayer:self withCacheProgress:progress];
            if(progress==1)
                _bufferEnd=YES;
        }
    }else if([keyPath isEqualToString:@"error"]){
        if([self.delegate respondsToSelector:@selector(videoPlayerDidError:)]){
            [self.delegate videoPlayerDidError:playerItem.error];
        }
        [self.toolView showError];
    }
}
-(BOOL)isPlaying{
    return self.HPlayer.rate&&self._isPlayed;
}
-(void)play{
    //移除上一个item的监听  和初始化设置
    [self removeObserverFromItem:self.HPlayer.currentItem];
    HVideoPlayView *view =[(HVideoItem *)self.HPlayer.currentItem observer];
    view._isPlayed=NO;
    AVPlayerItem *item=[[HVideoItem alloc]initWithURL:self.url];
    [self.layer addSublayer:_HPlayerLayer];
    [self.HPlayerLayer.player replaceCurrentItemWithPlayerItem:item];
    [self addObserverFromItem:item];
    [self.HPlayer play];
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidBeginPlay:)]) {
        [self.delegate videoPlayerDidBeginPlay:self];
    }
    self._isPlayed=YES;

}
-(void)switchUseURL:(NSURL *)url{
    self.url = url;
    self._isPlayed=NO;
}
-(void)pause{
    if (self.HPlayer.rate==1) {
        [self.HPlayer pause];
    }
}
-(void)resume{
    if(self.HPlayer.rate==0){
        [self.HPlayer play];
    }
}

-(double)duration{
    return _currentVeidoDuration;
}
-(double)currentTime{
    return  CMTimeGetSeconds(self.HPlayer.currentItem.currentTime);
}
-(double)cachaProgress{
    return self._cacheProgress;
}
-(void)seekToTime:(double)time {
    /**
     CMTimeMake(a,b)    a当前第几帧, b每秒钟多少帧.当前播放时间a/b
     
     CMTimeMakeWithSeconds(a,b)    a当前时间,b每秒钟多少帧.
     */
    [self.HPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
-(void)seeKToDate:(NSDate*)date{
    [self.HPlayer pause];
    [self.HPlayer seekToDate:date];
    [self play];
}

-(void)dealloc{
    [self clearData];
}
-(void)clearData{
    [self removeObserverFromItem:self.HPlayer.currentItem];
    [self pause];
    [self seekToTime:0];
    [self.toolView initStatus];
    [self.HPlayer replaceCurrentItemWithPlayerItem:nil];
    self._isPlayed=NO;
}
- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    NSLog(@"%@",self.superview);
}
-(void)removeFromSuperview{
    [super removeFromSuperview];
    [self clearData];
    [self.toolView initStatus];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.toolView setFrame:self.bounds];
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL flag = [super pointInside:point withEvent:event];
    if (!flag){
        if (![self isDisplayedInScreen]) {
            [self clearData];
        }
    }
    return flag;
}


#pragma -mark  CustomPlayerDelegate

-(UIView *)playView{
    return self;
}


@end

@implementation HVideoPlayView (delegate)

-(BOOL)toolView:(HPlayToolView *)view play:(BOOL)flag{
    if (flag) {
        self._isPlayed?[self resume]:[self play];
    }else{
        [self pause];
    }
    return YES;
}

-(void)toolView:(HPlayToolView *)view changeProgress:(double)time{
    [self seekToTime:time * _currentVeidoDuration];
}

-(void)toolViewToScreen:(HPlayToolView *)view{
    NSLog(@"全屏");
}
@end


