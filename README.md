#### 使用operation实现的版本(推荐)
支持媒体并发控制，支持单个媒体文件并发控制。支持任务取消，支持任务挂起和恢复。

地址：[https://github.com/zmubai/M3U8DemoByOperation.git](https://github.com/zmubai/M3U8DemoByOperation.git)


###  m3u8缓存本地播放
#### 使用方法
1.发起下载
``` 
//urlStr必须为二级索引文件url，不能为多码流选择的一级索引文件rul
- (void)downloadVideoWithUrlString:(NSString *)urlStr
downloadProgressHandler:(ZBLM3u8ManagerDownloadProgressHandler)downloadProgressHandler
downloadResultBlock:(ZBLM3u8ManagerDownloadResultBlock) downloadResultBlock;
```

```
[[ZBLM3u8Manager shareInstance] downloadVideoWithUrlString:url downloadProgressHandler:^(float progress) {
    dispatch_async(dispatch_get_main_queue(), ^{
        ...更新进度
    });
    } downloadResultBlock:^(NSString * _Nonnull localPlayUrlString, NSError * _Nullable error) {
    if (!error) {
    //下载成功
    //打开本地http服务
    [[ZBLM3u8Manager shareInstance]  tryStartLocalService];
    ...根据url播放
    }
}];

```

2.取消下载
```
- (void)cannelDownloadWithUrl:(NSString *)url;
```

3.http服务控制
```
@interface ZBLHttpLocalServer : NSObject
@property (strong, nonatomic) NSString *documentRoot;
@property (assign, nonatomic) NSInteger port;
+ (instancetype)shareInstance;
- (void)tryStart;
- (void)tryStop;
@end
```

4.url文件相关
```
/*清空根目录*/
- (void)clearRootFilePath;
/*根据url判断视频是否已经缓存*/
- (BOOL)exitLocalVideoWithUrlString:(NSString*) urlStr;
/*根据网络url映射出本地url*/
- (NSString *)localPlayUrlWithOriUrlString:(NSString *)urlString;
```

5.相关配置
```
#pragma mark - service
+ (NSString *)localHost
{
    return @"http://127.0.0.1:8080";
}
+ (NSString *)port
{
    return @"8080";
}

#pragma mark - dir/fileName
+ (NSString *)commonDirPrefix
{
    return  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"m3u8files"];
}
+ (NSString *)m3u8InfoFileName
{
    return @"movie.m3u8";
}

+ (NSString *)oriM3u8InfoFileName
{
    return @"oriMovie.m3u8";
}

+ (NSString *)keyFileName
{
    return @"key";
}
+ (NSString *)uuidWithUrl:(NSString *)Url
{
    return [Url md5];
}
+ (NSString *)fullCommonDirPrefixWithUrl:(NSString *)url
{
    return [[self commonDirPrefix] stringByAppendingPathComponent:[self uuidWithUrl:url]];
}
+ (NSString *)tsFileWithIdentify:(NSString *)identify;
{
    return [NSString stringWithFormat:@"%@.ts",identify];
}
```

