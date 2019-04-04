//
//  ZBLM3u8Manager.h
//  m3u8DownloadSimpleDemo
//
//  Created by Bennie on 2019/4/4.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZBLM3u8ManagerDownloadSuccessBlock)(NSString *localPlayUrlString);
typedef void (^ZBLM3u8ManagerDownloadProgressHandler)(float progress);
@interface ZBLM3u8Manager : NSObject
+ (instancetype)shareInstance;

- (void)clearRootFilePath;

- (BOOL)exitLocalVideoWithUrlString:(NSString*) urlStr;

- (NSString *)localPlayUrlWithOriUrlString:(NSString *)urlString;

- (void)downloadVideoWithUrlString:(NSString *)urlStr downloadProgressHandler:(ZBLM3u8ManagerDownloadProgressHandler)downloadProgressHandler downloadSuccessBlock:(ZBLM3u8ManagerDownloadSuccessBlock) downloadSuccessBlock;

- (void)cannelDownloadWithUrl:(NSString *)url;

- (void)tryStartLocalService;

- (void)tryStopLocalService;
@end

NS_ASSUME_NONNULL_END