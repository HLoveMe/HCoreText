利用CoreText对C函数进行封装，达到更简单的调用
   支持
   
            AAAA <link url="" ...>                   url size name color underLine UnderColor 
            
            BBB <font  size=""...> 所有支持的关键字 size name color underLine UnderColor 
            
            CCCC <image src="" ...>                 src width height
   格式的解析文本   
   
   新增：
         @[
         
            @{
            
               @"content":@"@爱上无名氏",
               
               @"type":@"link",
               
               @"url":@"http://www.baidu.com",
               
               @"size":@"18",
               
               @"color":@"red"
               
            },
            
            @{
            
               @"content":@" ",
               
               @"type":@"image",
               
               @"src":@"http://imgsrc.baidu.com/forum/pic/item/cdbf6c81800a19d8d8a3f94a33fa828ba71e46d8.jpg",
               
               @"width":@"200",
               
               @"height":@"120"
               
            },
            
            @{
            
               @"content":@"I love you 无名氏个大傻逼",
               
               @"type":@"text",
               
               @"color":@"blue",
               
               @"size":@"18",
               
               @"name":@"Futura"
               
            }
            
         ]
      格式的文本解析支持   
   
使用：
   
   创建FrameParserConfig类的对象（该类是对整体解析进行配置）
   
   利用FrameParser提供的方法，对文本进行解析
      
       1：+(CoreTextData *)parserContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC parserDelegate:(id<FrameParserDelegate>)delegate
        使用该方法你需要提供完整的解析流程参数（如何把整块分片，如何从片中得到文本参数等），FrameParserDelegate.h是整个流程的代理者通过实现该协议的必要方法为解析提供必要参数
    
       2：+(CoreTextData *)parserWithPropertyContent:(NSString *)content defaultCfg:(FrameParserConfig *)defaultC
           该方式是对上面(1)解析的一个具体实现的一个调用 （FrameParserHandle.h为实现代理的对象）
           提供：I<font name=\"XX\" size=\"20\" color=\"blue\"> 
                 Love<font name=\"XX\" size=\"12\" color=\"red\">
                 <image src="" withd="" height="">you<font name=\"\" size=\"25\">
                 @爱上无名氏<link src="" size="">
               格式文本的解析
               
      3：+(CoreTextData *)parserWithSource:(NSArray<NSDictionary<NSString * ,NSString *>*> *)content     defaultCfg:(FrameParserConfig *)defaultC;   
       
          
      解析得到解析之后的CoreTextData对象
   
      使用对CTDrawView @Selector(drawWithCoreTextData:)进行绘制 
         1：用于对渲染内容的展示
      
         2：支持点击内容回调（具体请看CTDrawView.h 文件）
   
   
   HImageBox 是针对该解析提供的简单的图片缓存实现 
   
      
   Note:   (A:如果使用默认解析方式，你不需要关注内部实现
         B:开发者自己实现
         * 实现FrameParserDelegate必要的方法 
       
         >paragraphConfig 段落配置 提供默认
         >FontConfig 字体配置 有默认
         >Message 是利用解析出来的参数 和解析的文本等 创建出来的对象 ，其包含每一小块的全部信息
          （使用其子类TextMessage,TextLinkMesssage,ImageMessage）
            
      )
      
