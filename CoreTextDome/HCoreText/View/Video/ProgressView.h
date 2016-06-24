//
//  ProgressView.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/22.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProgressView;
@protocol ProgressDelegate<NSObject>
@optional
-(void)progressView:(ProgressView*)view progress:(double)pro;
-(void)progressViewDidFinshDrag:(ProgressView*)view;
-(void)progressViewToSrceen:(ProgressView*)view;
@end
@interface ProgressView : UIView
@property(nonatomic,weak)id<ProgressDelegate> delegate;
-(void)setCurrentTime:(double)time;
-(void)setTotalTime:(double)time;
-(void)setCacheProgress:(double)pro;
@end
