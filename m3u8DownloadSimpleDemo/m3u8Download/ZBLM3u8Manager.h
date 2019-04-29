//
//  ZBLM3u8Manager.h
//  m3u8DownloadSimpleDemo
//
//  Created by Bennie on 2019/4/4.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZBLM3u8ManagerDownloadResultBlock)(NSString * _Nullable localPlayUrlString,  NSError * _Nullable error);
typedef void (^ZBLM3u8ManagerDownloadProgressHandler)(float progress);
@interface ZBLM3u8Manager : NSObject
+ (instancetype)shareInstance;

- (void)clearRootFilePath;

- (BOOL)exitLocalVideoWithUrlString:(NSString*) urlStr;

- (NSString *)localPlayUrlWithOriUrlString:(NSString *)urlString;

- (void)downloadVideoWithUrlString:(NSString *)urlStr
           downloadProgressHandler:(ZBLM3u8ManagerDownloadProgressHandler)downloadProgressHandler
               downloadResultBlock:(ZBLM3u8ManagerDownloadResultBlock) downloadResultBlock;

- (void)cannelDownloadWithUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
