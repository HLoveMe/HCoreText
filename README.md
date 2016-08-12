优化事件回调 并支持视频播放

利用CoreText对C函数进行封装，达到更简单的调用  支持格式
   
            AAAA <link url="" ...>                   url size name color underLine underColor
            
            BBB <font  size=""...> 所有支持的关键字 size name color underLine UnderColor 
            
             <image src="" ...>                 src width height isReturn isCenter
            
             <video src="" ...>                 src width height isReturn isCenter
      
      size(字体大小) name（字体name） color(字体颜色red-->redColor 或者十六进制颜色) underLine(下划线样式)       underColor(下划线颜色)    针对Fontconfig 属性
      
      url(点击跳转url)          针对TextLinkMessage URLSrc
      
      src width height          针对ImageMessage 属性
   
      isReturn isCenter        针对图片和视频  isReturn表示是否换行显示  isCenter是否显示在行center
      
   新增：格式的文本解析支持   
   
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
            ,
            
         @{
       
               @"type":@"video",
            
               @"src":@"",
            
               @"width":@"260",
            
               @"height":@"120"
            
             }
            
         ]
   
      text:content type size color underLine underColor name  所有关键字 前两者是必须的      
       
      link:content type size url color underLine underColor name  所有关键字 前两者是必须的
      
      image : content type src width height 所有关键字 前两者是必须的
      
   emoji表情的支持：
      由于不同需求Emoji显示方式不一样
      
         本例 ：               :+1:  -----> 赞(\U0001F44D)
         
         可能你的实例需要       [emoji]赞[/emoji]  - >赞(\U0001F44D)
         
      配置 FrameParserConfig  并替换emoji.plist 
      
   视频支持:
   
         本例提供的播放器组件只是Dome使用  建议替换为您功能更加齐全的播放器。(在每个video 所在的地方都会加载你的播放器，您必须要控制内存使用，比如说使用单利).您必须已经处理好所有播放事件 
         
   CTDrawView--代理-->CTViewTouchDelegate:
   
      该框架为CTDrawView 提供默认的代理CTDrawManager（在事件发生后 发出通知）
   
         
Note:两种解析方式 支持的关键字是一致的
   
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
          （使用其子类TextMessage,TextLinkMesssage,ImageMessage，VideoMessage）
            
      )
      
