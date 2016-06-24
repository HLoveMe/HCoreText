//
//  HVideoPlayer.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/23.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
@class HVideoPlayView;
@interface HVideoPlayer : AVPlayerLayer
+(instancetype)sharedPlayer;
@end

@interface HVideoItem : AVPlayerItem
@property(nonatomic,assign)BOOL isRegistered;
@property(nonatomic,weak)HVideoPlayView * observer;
@end