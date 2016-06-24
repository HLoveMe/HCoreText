//
//  CTDrawManager.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/6/21.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
//当文本被点击
FOUNDATION_EXPORT NSString  const * CTTextDidTouchNotifacation;
//当Link文本被点击
FOUNDATION_EXPORT NSString  const * CTLinkDidTouchNotifacation;
//当图片被点击
FOUNDATION_EXPORT NSString  const * CTImageDidTouchNotifacation;

//播放视频
FOUNDATION_EXPORT NSString  const * CTVideoDidPlayNotifacation;

//暂停
FOUNDATION_EXPORT NSString  const *CTVideoDidPauseNotifacation;

@interface CTDrawManager : NSObject

@end


