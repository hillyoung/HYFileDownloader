//
//  HYFileDownloadQueue.h
//  HYFileDownloader
//
//  Created by yanghaha on 16/7/17.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HYFileDownloader;

#pragma mark - HYFileDownloadTask -----------------------------

/**
 *  单个文件下载任务
 */
@interface HYFileDownloadTask : NSObject <NSCoding>

/**
 *  下载任务
 */
@property (weak, nonatomic) NSURLSessionDataTask *task ;

/**
 *  下载输出流
 */
@property (strong, nonatomic) NSOutputStream *stream ;

/**
 *  下载任务的名字
 */
@property (copy, nonatomic) NSString *title;

/**
 *  文件源地址
 */
@property (copy, nonatomic) NSString *urlStr;

/**
 *  文件相对路径
 */
@property (copy, nonatomic) NSString *filePath;

/**
 *  当前已完成下载大小
 */
@property (nonatomic) int64_t currentLength;

/**
 *  文件总大小
 */
@property (nonatomic) int64_t contentLength;

/**
 *  完成进度的回调
 */
@property (copy, nonatomic) void(^progressBlock)(HYFileDownloadTask *task, double progress);

/**
 *  初始化一个下载任务
 */
- (instancetype)initWithTitle:(NSString *)title ulrstr:(NSString *)urlStr filePath:(NSString *)filePath contentLength:(int64_t)contentLength ;

/**
 *  暂停下载任务
 */
- (void)suspend ;

/**
 *  队列开始工作
 */
- (void)resume ;

/**
 *  下载任务保存plist的地址
 */
+ (NSString *)fileForDownload ;

@end

#pragma mark - HYFileNoMoveDownloadTask -----------------------------

//下载完成后不需要移动的下载任务
@interface HYFileNoMoveDownloadTask : HYFileDownloadTask

- (BOOL)isCacheInDownloader:(HYFileDownloader *)downloader ;

@end

#pragma mark - HYFileDownloader -----------------------------

/**
 *  文件下载完成,通知名
 */
static NSString *const HYFileDownloadTaskDidFinished = @"HYFileDownloadTaskDidFinished";

/**
 *  文件下载任务队列的下载器
 */
@interface HYFileDownloader : NSObject

/**
 *  最大下载数
 */
@property (nonatomic) NSUInteger maxDownloadCount;

/**
 *  下载中的任务
 */
@property (readonly, strong, nonatomic) NSMutableArray<HYFileDownloadTask *> *downloadingTasks;

/**
 *  下载完成的任务
 */
@property (readonly, strong, nonatomic) NSMutableArray<HYFileDownloadTask *> *downloadedTasks;

/**
 *  缓存文件的后缀名；
 *  无后缀名，则表示直接写入文件中，下载完成后不需要重命名或者移动文件
 */
@property (copy, nonatomic) NSString *suffix;

/**
 *  缓存的路径
 */
@property (copy, nonatomic) NSString *cachePath;

+ (instancetype)defaultDownloader ;

/**
 *  加载缓存的下载列表
 */
- (void)loadAllItems ;

/**
 *  添加一个下载任务
 */
- (void)addTask:(HYFileDownloadTask *)task ;

/**
 *  移除指定下载任务
 */
- (void)removeTask:(HYFileDownloadTask *)task ;

/**
 *  合成数据(进入后台，或者是杀掉进程时)
 */
- (void)synchronize ;

/**
 *  根据下载任务，返回对应的缓存文件路径(绝对路径)
 *
 *  @param task 指定的下载任务
 *
 *  @return 返回对应的缓存文件路径(绝对路径)
 */
+ (NSString *)tempPathForFilePath:(HYFileDownloadTask *)task ;

/**
 *  根据下载任务，解析出对应的文件绝对路径
 *
 *  @param task 指定的下载任务
 *
 *  @return 解析出对应的文件路径(相对路径)
 */
+ (NSString *)absolutePathForFilePath:(HYFileDownloadTask *)task ;

@end
