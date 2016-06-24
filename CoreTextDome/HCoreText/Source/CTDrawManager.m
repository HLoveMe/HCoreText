//
//  CTDrawManager.m
//  CoreTextDome
//k
//  Created by 朱子豪 on 16/6/21.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "CTDrawManager.h"
#import "CTDrawView.h"
 NSString const* CTTextDidTouchNotifacation = @"textDidTouchNotifacation";
 NSString const* CTLinkDidTouchNotifacation = @"linkDidTouchNotifacation";
 NSString const* CTImageDidTouchNotifacation = @"imageDidTouchNotifacation";

NSString const* CTVideoDidPlayNotifacation = @"CTVideoDidPlayNotifacation";
NSString const* CTVideoDidPauseNotifacation = @"CTVideoDidPauseNotifacation";


@interface CTDrawManager()<CTViewTouchDelegate>

@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
@implementation CTDrawManager
-(void)touchView:(UIView *)view contentString:(NSString *)content{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTTextDidTouchNotifacation object:content];
}
-(UIColor *)touchView:(UIView *)view contentString:(NSString *)content URLString:(NSString *)urlString{
    NSDictionary *dic =@{@"content":content,@"urlString":urlString};
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLinkDidTouchNotifacation object:dic];
    return [UIColor orangeColor];
}
-(void)touchView:(UIView *)view imageName:(NSString *)source{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTImageDidTouchNotifacation object:source];
}
-(void)touchView:(UIView *)view player:(id<CustomPlayerDelegate>)player videoSource:(NSString *)source{
    NSDictionary *dic =@{@"target":view,@"player":player,@"urlString":source};
    if ([player isPlayed]) {
        if([player isPlaying]){
            [player pause];
            [[NSNotificationCenter defaultCenter] postNotificationName:CTVideoDidPauseNotifacation object:dic];
        }else{
            [player resume];
            [[NSNotificationCenter defaultCenter] postNotificationName:CTVideoDidPlayNotifacation object:dic];
        }
    }else{
        [player play];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTVideoDidPlayNotifacation object:dic];
    }
}
@end
#pragma clang diagnostic pop