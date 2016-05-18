//
//  paragraphConfig.m
//  CoreTextDome
//
//  Created by space on 16/4/25.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "paragraphConfig.h"
@implementation paragraphConfig
-(instancetype)init{
    if (self = [super init]) {
        self.alignment = kCTTextAlignmentNatural;
        self.firstLineHeadIndent = 0.0;
        self.headIndent =0.0;
        self.tailIndent = 0.0;
        self.breakMode = kCTLineBreakByWordWrapping;
        self.lineSpace = 1.0;
        self.MinLineSpace = 0.0;
        self.MaxLineSpace = CGFLOAT_MAX;
        self.direction = kCTWritingDirectionNatural;
        
    }
    return  self;
}
-(CTParagraphStyleRef)getStyle:(BOOL)defaultConfig{
    CTTextAlignment alignment   = defaultConfig?kCTTextAlignmentNatural:self.alignment;
    CGFloat firstLineIndent     = defaultConfig?0.0:self.firstLineHeadIndent;
    CGFloat topIndent           = defaultConfig?0.0:self.headIndent;
    CGFloat bottpmIndent        = defaultConfig?0.0:self.tailIndent;
    CTLineBreakMode mode        = defaultConfig?kCTLineBreakByWordWrapping:self.breakMode;
    CGFloat lineSpace           = defaultConfig?0.0:self.lineSpace;
    CGFloat minSpace            = defaultConfig?0.0:self.MinLineSpace;
    CGFloat maxSpace            = defaultConfig?CGFLOAT_MAX:self.MaxLineSpace;
    CTWritingDirection direcion = defaultConfig?kCTWritingDirectionNatural:self.direction;
    CTParagraphStyleSetting setting[9] = {
        {kCTParagraphStyleSpecifierAlignment,sizeof(uint8_t),&alignment},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(CGFloat),&firstLineIndent},
        {kCTParagraphStyleSpecifierHeadIndent,sizeof(CGFloat),&topIndent},
        {kCTParagraphStyleSpecifierTailIndent,sizeof(CGFloat),&bottpmIndent},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(uint8_t),&mode},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&minSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&maxSpace},
        {kCTParagraphStyleSpecifierBaseWritingDirection,sizeof(uint8_t),&direcion}
    };
    CTParagraphStyleRef ref = CTParagraphStyleCreate(setting, 9);
    return ref;

}
+(CTParagraphStyleRef)defaultConfig{
    return [[[paragraphConfig alloc]init] getStyle:YES];
}
-(CTParagraphStyleRef)style{
    return [self getStyle:NO];
}
@end
