//
//  ParserType.h
//  CoreTextDome
//
//  Created by 朱子豪 on 16/5/18.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#ifndef ParserType_h
#define ParserType_h
/**
 *  enum 来标记该段内容是形式
 *   TextType 文本内容
 *   LinkType
 *   ImageType 图片内容
 */
typedef enum{
    TextType = 1,
    LinkType,
    ImageType
}SourceType;

#endif
