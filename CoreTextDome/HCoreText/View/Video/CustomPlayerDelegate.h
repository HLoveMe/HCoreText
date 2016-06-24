//
//  VideoPlayerDelegate.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/24.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#ifndef VideoPlayerDelegate_h
#define VideoPlayerDelegate_h
#import <UIKit/UIKit.h>
@protocol CustomPlayerDelegate<NSObject>
//是否已经开始播放
@property(nonatomic,assign,readonly)BOOL isPlayed;
//是否正在播放
@property(nonatomic,assign,readonly)BOOL isPlaying;
//得到播放视图
-(UIView *)playView;
//切换视频源
-(void)switchUseURL:(NSURL *)url;
//重头开始播放
-(void)play;
/**暂停*/
-(void)pause;
/**恢复*/
-(void)resume;

@end

#endif
