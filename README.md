利用CoreText对C函数进行封装，达到更简单的调用

使用：
   
   创建FrameParserConfig类的对象（该类是对整体解析进行配置）
   
   利用FrameParser提供的方法，对文本进行解析
    1：+(CoreTextData *)parserContent: defaultConfig: sectionHandle: partContentDeal:
        使用该方法你需要提供完整的解析流程参数（如何把整块分片，如何从片中得到文本参数）
    
    2：+(CoreTextData *)parserWithPropertyContent:  defaultConfig:
        该方式是对+(CoreTextData *)parserContent: defaultConfig: sectionHandle: partContentDeal:的一个调用 
        提供：I<font name=\"XX\" size=\"20\" color=\"blue\"> 
              Love<font name=\"XX\" size=\"12\" color=\"red\">
              <image src="" withd="" height="">you<font name=\"\" size=\"25\">
            格式文本的解析
    3:另一种解决方案（和上面的一致 只是实现原理不一样）        
    +(CoreTextData *)parserContent:defaultConfig: callBack:  
    +(CoreTextData *)parserWithPropertyContent2: defaultConfig:;       
