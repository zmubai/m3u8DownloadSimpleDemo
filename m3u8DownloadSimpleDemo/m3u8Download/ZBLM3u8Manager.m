//
//  ZBLM3u8Manager.m
//  m3u8DownloadSimpleDemo
//
//  Created by Bennie on 2019/4/4.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "ZBLM3u8Manager.h"
#import "ZBLM3u8FileManager.h"
#import "HTTPServer.h"
#import "ZBLM3u8Setting.h"
#import "ZBLM3u8DownloadContainer.h"

@interface ZBLM3u8Manager ()
@property (nonatomic, strong) NSMutableDictionary *downloadContainerDictionary;
@property (nonatomic, strong) dispatch_queue_t downloadQueue;
@property (strong, nonatomic) HTTPServer *httpServer;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@end

@implementation ZBLM3u8Manager
+ (instancetype)shareInstance
{
    static ZBLM3u8Manager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.downloadContainerDictionary = @{}.mutableCopy;
        sharedInstance.lock = dispatch_semaphore_create(1);
        sharedInstance.downloadQueue = dispatch_queue_create("ZBLM3u8Manager.download", DISPATCH_QUEUE_CONCURRENT);
    });
    return sharedInstance;
}

- (void)_lock{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
}

- (void)_unlock{
    dispatch_semaphore_signal(self.lock);
}

#pragma mark - public
- (void)clearRootFilePath
{
    [[ZBLM3u8FileManager shareInstance]removeFileWithPath:[ZBLM3u8Setting commonDirPrefix]];
}

- (BOOL)exitLocalVideoWithUrlString:(NSString*) urlStr
{
    return [ZBLM3u8FileManager exitItemWithPath:[[ZBLM3u8Setting commonDirPrefix] stringByAppendingPathComponent:[[ZBLM3u8Setting uuidWithUrl:urlStr] stringByAppendingString:[ZBLM3u8Setting m3u8InfoFileName]]]];
}

- (NSString *)localPlayUrlWithOriUrlString:(NSString *)urlString
{
    return  [NSString stringWithFormat:@"%@/%@/%@",[ZBLM3u8Setting localHost],[ZBLM3u8Setting uuidWithUrl:urlString],[ZBLM3u8Setting m3u8InfoFileName]];
}

- (void)downloadVideoWithUrlString:(NSString *)urlStr downloadProgressHandler:(ZBLM3u8ManagerDownloadProgressHandler)downloadProgressHandler downloadResultBlock:(ZBLM3u8ManagerDownloadResultBlock) downloadResultBlock
{
    dispatch_async(_downloadQueue, ^{
        __weak __typeof(self) weakself = self;
        ZBLM3u8DownloadContainer *dc = [self downloadContainerWithUrlString:urlStr];
        [dc downloadWithUrlString:urlStr  downloadProgressHandler:^(float progress) {
            downloadProgressHandler(progress);
        } completaionHandler:^(NSString *locaLUrl, NSError *error) {
            if (!error) {
                [weakself _lock];
                [weakself.downloadContainerDictionary removeObjectForKey:[ZBLM3u8Setting uuidWithUrl:urlStr]];
                [weakself _unlock];
                NSLog(@"下载完成:%@",urlStr);
                if (downloadResultBlock) {
                    downloadResultBlock(locaLUrl,nil);
                }
            }
            else
            {
                if (downloadResultBlock) {
                    downloadResultBlock(nil,error);
                }
                NSLog(@"下载失败:%@",error);
            }
#ifdef DEBUG
            [weakself _lock];
            NSLog(@"%@",weakself.downloadContainerDictionary.allKeys);
            [weakself _unlock];
#endif
        }];
    });
}

- (void)cannelDownloadWithUrl:(NSString *)url
{
    ZBLM3u8DownloadContainer *dc = [self downloadContainerWithUrlString:url];
    [dc cannel];
}

#pragma mark -
- (ZBLM3u8DownloadContainer *)downloadContainerWithUrlString:(NSString *)urlString
{
    [self _lock];
    ZBLM3u8DownloadContainer *dc = [_downloadContainerDictionary valueForKey:[ZBLM3u8Setting uuidWithUrl:urlString]];
    [self _unlock];
    if (!dc) {
        dc = [ZBLM3u8DownloadContainer  new];
        [self _lock];
        [_downloadContainerDictionary setValue:dc forKey:[ZBLM3u8Setting uuidWithUrl:urlString]];
        [self _unlock];
    }
    return dc;
}

#pragma mark - service
- (void)tryStartLocalService
{
    /*多线程不可重入*/
    @synchronized (self) {
        if (!self.httpServer) {
            self.httpServer=[[HTTPServer alloc]init];
            [self.httpServer setType:@"_http._tcp."];
            [self.httpServer setPort:[ZBLM3u8Setting port].integerValue];
            [self.httpServer setDocumentRoot:[ZBLM3u8Setting commonDirPrefix]];
            NSError *error;
            if ([self.httpServer start:&error]) {
                NSLog(@"开启HTTP服务器 端口:%hu",[self.httpServer listeningPort]);
            }
            else{
                NSLog(@"服务器启动失败错误为:%@",error);
            }
        }
        else if(!self.httpServer.isRunning)
        {
            [self.httpServer start:nil];
        }
    }
}

- (void)tryStopLocalService
{
    @synchronized (self) {
        if([self.httpServer isRunning])
            [self.httpServer stop:YES];
    }
}

@end
