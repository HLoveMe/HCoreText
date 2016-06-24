//
//  ProgressView.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/22.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "ProgressView.h"
#import "HProgressSlider.h"
#import "UIView+Extension.h"
@interface ProgressView()
@property(nonatomic,strong)UILabel *currenTimeLab;
@property(nonatomic,strong)UILabel *totalTimeLab;
@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)HProgressSlider *progressSlider;
@property(nonatomic,assign)double totalTime;
@end
@implementation ProgressView

-(instancetype)initWithFrame:(CGRect)frame{
    CGRect rect=CGRectMake(0, frame.origin.y, frame.size.width, 20);
    if (self=[super initWithFrame:rect]) {
        self.backgroundColor=[UIColor blackColor];
        self.alpha=0.8;
        self.currenTimeLab=[UILabel new];
        self.currenTimeLab.font=[UIFont systemFontOfSize:8];
        self.currenTimeLab.textAlignment=NSTextAlignmentRight;
        self.currenTimeLab.textColor = [UIColor whiteColor];
        
        self.totalTimeLab=[UILabel new];
        self.totalTimeLab.font=[UIFont systemFontOfSize:8];
        self.totalTimeLab.textAlignment=NSTextAlignmentLeft;
        self.totalTimeLab.textColor = [UIColor whiteColor];
        
        self.button=[UIButton new];
        [self.button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.progressSlider=[HProgressSlider new];
        self.progressSlider.maximumValue=1.0;
        [self.progressSlider addTarget:self action:@selector(progressCahnge:) forControlEvents:UIControlEventValueChanged];
        [self.progressSlider addTarget:self action:@selector(dragEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [self.progressSlider setThumbImage:[UIImage imageNamed:@"sourceImages.bundle/thumb"] forState:UIControlStateNormal];
        self.progressSlider.minimumTrackTintColor=[UIColor redColor];
        
        [self addSubview:self.currenTimeLab];
        [self addSubview:self.progressSlider];
        [self addSubview:self.totalTimeLab];
        [self addSubview:self.button];
        
        
        self.currenTimeLab.text=@"00:00";
        self.totalTimeLab.text=@"00:00";
        self.button.backgroundColor=[UIColor orangeColor];
    }
    return self;
}

-(void)setCurrentTime:(double)time{
    self.currenTimeLab.text=[self parserTime:time];
    if (self.totalTime>=1) {
        [self.progressSlider setValue:time/self.totalTime animated:YES];
    }
    
}
-(void)setTotalTime:(double)time{
    if (self.totalTime>=1)
        return;
    self.totalTimeLab.text=[self parserTime:time];
    _totalTime=time;
    
}
-(void)setCacheProgress:(double)pro{
    [self.progressSlider setCacheProgress:pro];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.width>=260){
        self.currenTimeLab.frame=CGRectMake(0, 0, self.width *0.10, self.height);
        self.progressSlider.frame=CGRectMake(self.width *0.12, 0, self.width*0.66, self.height);
        self.totalTimeLab.frame=CGRectMake(self.width * 0.8, 0, self.width * 0.1, self.height);
        self.button.frame=CGRectMake(self.width*0.9, 0, self.width*0.1, self.height);
    }else{
        self.progressSlider.frame=CGRectMake(self.width *0.075, 0, self.width*0.75, self.height);
        self.button.frame=CGRectMake(self.width*0.9, 0, self.width*0.1, self.height);
    }
    
    
}
#pragma -mark 事件
-(void)buttonClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(progressViewToSrceen:)]) {
        [self.delegate progressViewToSrceen:self];
    }
}
-(void)progressCahnge:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(progressView:progress:)]) {
        [self.delegate progressView:self progress:slider.value];
    }
}

-(void)dragEnd:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(progressViewDidFinshDrag:)]) {
        [self.delegate progressViewDidFinshDrag:self];
    }
}

-(NSString *)parserTime:(double)time{
    int hour = (int)time / 3600;
    int min = (int)(time-hour*3600) / 60;
    int s = (int)(time-hour*3600 - min * 60);
    
    NSString * hourStr = [NSString stringWithFormat:@"%d",hour];
    if (hour<10&&hour>0) {
        hourStr=[NSString stringWithFormat:@"0%d",hour];
    }
    
    NSString * minStr = [NSString stringWithFormat:@"%d",min];
    if (min<10) {
        minStr=[NSString stringWithFormat:@"0%d",min];
    }
   
    NSString * sStr = [NSString stringWithFormat:@"%d",s];
    if (s<10) {
        sStr=[NSString stringWithFormat:@"0%d",s];
    }
    
    NSString *content;
    if (hour>=1) {
        content=[NSString stringWithFormat:@"%@:%@:%@",hourStr,minStr,sStr];
    }else{
        content=[NSString stringWithFormat:@"%@:%@",minStr,sStr];
    }
    return content;
}
@end
