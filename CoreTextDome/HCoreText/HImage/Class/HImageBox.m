//
//  HImageBox.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/3.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "HImageBox.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#define HCacheImagePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"imageCache"]
@implementation HImageBox
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:HCacheImagePath]) {
            [manager createDirectoryAtPath:HCacheImagePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [HImageBox removeTimeOutFile];
    });
}
+(void)removeTimeOutFile{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        [[manager contentsOfDirectoryAtPath:HCacheImagePath error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path =[HCacheImagePath stringByAppendingPathComponent:obj];
            NSDictionary *dic =  [manager attributesOfItemAtPath:path error:nil];
            NSDate *date= dic[NSFileCreationDate];
            long time1 = [date timeIntervalSince1970];
            long time2 = [[NSDate date] timeIntervalSince1970];
            if ((time2-time1)>= 7 *24 *3600) {
                [manager removeItemAtPath:path error:nil];
            }
        }];
    });
}
+(void)removeAllFile{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        [[manager contentsOfDirectoryAtPath:HCacheImagePath error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path =[HCacheImagePath stringByAppendingPathComponent:obj];
            [manager removeItemAtPath:path error:nil];
        }];
    });
}
+(void)getImageWithSource:(NSString *)src option:(void(^)(UIImage *img,BOOL isFirst))block{
    NSAssert(block, @"回调不能为空");
    __block UIImage *image = [UIImage imageNamed:src];
    if (image) {return block(image,NO);}
    NSURLSessionConfiguration * sessionCfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSString *imageName = [src lastPathComponent];
    NSString *imagePath = [HCacheImagePath stringByAppendingPathComponent:imageName];
    image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {return block(image,NO);}
    
    NSURL *url = [NSURL URLWithString:src];
    if (image) {return block(nil,NO);}
    UIApplication *app = [UIApplication sharedApplication];
    NSMutableDictionary *dic = objc_getAssociatedObject(app, "imageDataTask");
    if (dic) {
        NSURLSessionDataTask *dataTask = [dic objectForKey:imagePath];
        if (dataTask) {
            return;
        }
    }else{
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(app, "imageDataTask", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionCfg];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [data writeToFile:imagePath atomically:YES];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    block(image,YES);
                });
            });
        }
        [dic removeObjectForKey:imagePath];
        if (dic.count==0) {
            objc_removeAssociatedObjects(app);
        }else{
            objc_setAssociatedObject(app, "imageDataTask", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
    [dataTask resume];
    dic[imagePath] = dataTask;
    
}
+(void)getFrameImageWithURL:(NSURL *)url atTime:(double)time option:(void(^)(UIImage *img))option{
    __block UIImage *img;
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
            AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            assetImageGenerator.appliesPreferredTrackTransform = YES;
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
            
            CGImageRef thumbnailImageRef = NULL;
            CFTimeInterval thumbnailImageTime = time;
            NSError *thumbnailImageGenerationError = nil;
            thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
            
            img = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
            if (thumbnailImageRef) {
                CFRelease(thumbnailImageRef);
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                option(img);
            });
        });
        
    }
}
@end
