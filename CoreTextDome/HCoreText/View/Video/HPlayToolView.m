//
//  HPlayToolView.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/22.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "HPlayToolView.h"
#import "ProgressView.h"
#import "HVideoPlayView.h"
#import "UIView+Extension.h"
#import "LLARingSpinnerView.h"
@interface HPlayToolView()<ProgressDelegate>{
    BOOL finish;
}
@property(nonatomic,strong)UIButton *centerButton;
@property(nonatomic,strong)ProgressView *progressView;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSTimer *cacheTimer;
@end

@implementation HPlayToolView
-(NSTimer *)cacheTimer{
    if (nil==_cacheTimer) {
        _cacheTimer =[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(changeCache:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_cacheTimer forMode:NSRunLoopCommonModes];
        _cacheTimer.fireDate=[NSDate distantFuture];
    }
    return _cacheTimer;
}
-(NSTimer *)timer{
    if (_timer == nil) {
        _timer =[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(changeTime:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _timer.fireDate=[NSDate distantFuture];
    }
    return _timer;
}
-(UIButton *)centerButton{
    if(_centerButton==nil){
        _centerButton=[[UIButton alloc]init];
        _centerButton.userInteractionEnabled=0;
        _centerButton.layer.cornerRadius=20;
        _centerButton.layer.masksToBounds=1;
        [_centerButton addTarget:self action:@selector(centerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerButton;
}
-(ProgressView *)progressView{
    if (nil==_progressView) {
        _progressView=[[ProgressView alloc]initWithFrame:CGRectZero];
        _progressView.delegate=self;
    }
    return _progressView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor=[UIColor clearColor];
        [self initStatus];
    }
    return self;
}
-(void)centerButtonClick:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(toolView:play:)]) {
        if (!finish) {
            BOOL success= [self.delegate toolView:self play:![(HVideoPlayView *)self.delegate isPlaying]];
            if (!success){
                [self networkError];
            }else
                self.player.rate?[self showPausePlay]:[self showPreperPlay];
            return;
        }else{
            [(HVideoPlayView *)self.delegate play];
            [self showPausePlay];
            finish=NO;
            return;
        }
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _centerButton.userInteractionEnabled=1;
    if (![(HVideoPlayView *)self.delegate isPlayed]|finish) {
        [(HVideoPlayView *)self.delegate play];
        self.timer.fireDate=[NSDate distantPast];
        self.cacheTimer.fireDate=[NSDate distantPast];
        finish=NO;
        [self hiddenTool];
        return;
    }
    if (self.centerButton.superview==nil) {
        [self showTool];
    }else{
        [self hiddenTool];
    }
}
-(void)initStatus{
    [(UIView *)self.delegate addSubview:self];
    [self addSubview:self.centerButton];
    [self.progressView removeFromSuperview];
    [self showPreperPlay];
}
-(void)hiddenTool{
    [self.progressView removeFromSuperview];
    [self.centerButton removeFromSuperview];
}
-(void)showTool{
    [(UIView *)self.delegate addSubview:self];
    if(finish){
        [self showFinishPlay];
    }else if (self.player.rate) {
        [self showPausePlay];
    }else{
        [self addSubview:self.progressView];
        [self showPreperPlay];
    }
    
}
-(void)showPreperPlay{
    [self addSubview:_centerButton];
    [_centerButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sourceImages.bundle/%@", @"timg"]] forState:UIControlStateNormal];
}
-(void)showFinishPlay{
    [_centerButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sourceImages.bundle/%@", @"timg"]] forState:UIControlStateNormal];
    finish=YES;
    [self addSubview:_progressView];
    [self addSubview:_centerButton];
    self.timer.fireDate=[NSDate distantFuture];
    self.cacheTimer.fireDate=[NSDate distantFuture];
}
-(void)showPausePlay{
    [self addSubview:_progressView];
    [self addSubview:_centerButton];
    [_centerButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sourceImages.bundle/%@", @"zting"]] forState:UIControlStateNormal];
}
-(void)showError{
    [self show:@"播放错误"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initStatus];
    });
}
-(void)networkError{
    [self show:@"网络错误"];
}
-(void)show:(NSString *)msg{
    static BOOL flag;
    if (flag) {
        return;
    }
    [self hiddenTool];
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 35)];
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.layer.cornerRadius=4;
    button.layer.masksToBounds=1;
    [button setTitle:msg forState:UIControlStateNormal];
    button.userInteractionEnabled=0;
    button.center=self.center;
    [self addSubview:button];
    button.backgroundColor=[UIColor whiteColor];
    button.alpha=0.9;
    flag=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button removeFromSuperview];
        flag=NO;
    });
}
//-(void)showCache{
//    [self hiddenTool];
//    self.userInteractionEnabled=0;
//    LLARingSpinnerView *one =[[LLARingSpinnerView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
//    one.userInteractionEnabled=0;
//    one.center=self.center;
//    [self addSubview:one];
//    _isCaching=YES;
//    [one startAnimating];
//}
//-(void)endCache{
//    LLARingSpinnerView *one = self.subviews.lastObject;
//    [one stopAnimating];
//    _isCaching=NO;
//    [one removeFromSuperview];
//    self.userInteractionEnabled=1;
//}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize rect = self.frame.size;
    CGFloat wid=40;
    CGFloat leftRight = (rect.width-wid)/2;
    CGFloat topBottom = (rect.height-wid)/2;
    _centerButton.frame=CGRectMake(leftRight, topBottom, wid, wid);
    CGRect oneRect=CGRectMake(0, self.height-25, self.width, 25);
    self.progressView.frame=oneRect;
}
-(void)dealloc{
    [self.timer invalidate];
    [self.cacheTimer invalidate];
}
#pragma -mark 定时器
-(void)changeTime:(NSTimer *)timer{
    double time = [(HVideoPlayView *)self.delegate currentTime];
    double total = [(HVideoPlayView *)self.delegate duration];
    [self.progressView setTotalTime:total];
    [self.progressView setCurrentTime:time];
}
-(void)changeCache:(NSTimer *)timer{
    double pro = [(HVideoPlayView *)self.delegate cachaProgress];
    [self.progressView setCacheProgress:pro];
    if (pro>=0.999)
        self.cacheTimer.fireDate=[NSDate distantFuture];
}

@end



@implementation HPlayToolView (delegate)
-(void)progressView:(ProgressView*)view progress:(double)pro{
    finish=NO;
    self.timer.fireDate=[NSDate distantFuture];
    double total = [(HVideoPlayView *)self.delegate duration];
    [(HVideoPlayView *)self.delegate seekToTime:total * pro];
    [(HVideoPlayView *)self.delegate pause];
}
-(void)progressViewDidFinshDrag:(ProgressView*)view{
    [(HVideoPlayView *)self.delegate resume];
    [self showPausePlay];
    self.timer.fireDate=[NSDate distantPast];
}
-(void)progressViewToSrceen:(ProgressView*)view{
    if([self.delegate respondsToSelector:@selector(toolViewToScreen:)]){
        [self.delegate toolViewToScreen:self];
    }
}

@end
