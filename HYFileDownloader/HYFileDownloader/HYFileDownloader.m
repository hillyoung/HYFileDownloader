//
//  HYFileDownloader.m
//  HYFileDownloader
//
//  Created by yanghaha on 16/7/17.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "HYFileDownloader.h"

static NSMutableDictionary *downloadDict;

static NSString const *key_downloading = @"key_downloading";
static NSString const *key_downloaded = @"key_downloaded";

#pragma mark - HYFileDownloadTask ---------------------------------------

@implementation HYFileDownloadTask

#pragma mark - LifeCycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _urlStr = [aDecoder decodeObjectForKey:@"urlStr"];
        _filePath = [aDecoder decodeObjectForKey:@"filePath"];
        _contentLength = [[aDecoder decodeObjectForKey:@"contentLength"] longLongValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.urlStr forKey:@"urlStr"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:@(self.contentLength) forKey:@"contentLength"];
}

- (instancetype)initWithTitle:(NSString *)title ulrstr:(NSString *)urlStr filePath:(NSString *)filePath contentLength:(int64_t)contentLength {
    if (self = [super init]) {
        _title = title;
        _urlStr = urlStr;
        _filePath = filePath;
        _contentLength = contentLength;
    }

    return self;
}

#pragma mark - Setter && Getter

- (int64_t)currentLength {
    _currentLength = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *path = [HYFileDownloader tempPathForFilePath:self];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *dict = [fileManager attributesOfItemAtPath:path error:&error];
        if (dict && !error) {
            _currentLength = [dict fileSize];
        }
    }
    return _currentLength;
}

#pragma mark - Message

- (void)resume {

    if (self.task.state != NSURLSessionTaskStateRunning) {
        [self.task resume];
    }
}

- (void)suspend {

    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task suspend];
    }
}

- (void)cancel {
    if (self.task.state != NSURLSessionTaskStateCompleted) {
        [self.task cancel];
    }
}

/**
 *  下载任务保存地址
 */
+ (NSString *)fileForDownload {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:@"download.plist"];
}

//+ (void)addDownloadingItems:(NSArray *)items {
//    NSMutableArray *removes = [NSMutableArray array];   //将要移除的item
//    
//    NSMutableArray *downloadingCopy = [downloadDict[key_downloading] mutableCopy];
//    
//    if (!downloadingCopy) {
//        downloadingCopy = [NSMutableArray array];
//    }
//    
//    for (HYFileDownloadTask *willSaveItem in items) {
//        
//        [downloadingCopy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            
//            if ([[(HYFileDownloadTask *)obj urlStr] isEqualToString:willSaveItem.urlStr]) {
//                [removes addObject:obj];
//                *stop = YES;
//            }
//            
//        }];
//    }
//
//    [downloadingCopy removeObjectsInArray:removes];
//    [downloadingCopy addObjectsFromArray:items];
//    
//    [downloadDict setObject:downloadingCopy forKey:key_downloading];
//    
//    [self saveAllItems];
//}
//
//+ (void)addWaitingItems:(NSArray *)items {
//    
//    NSMutableArray *removes = [NSMutableArray array];   //将要移除的item
//    
//    NSMutableArray *waitingCopy = [downloadDict[key_downloaded] mutableCopy];
//    
//    if (!waitingCopy) {
//        waitingCopy = [NSMutableArray array];
//    }
//    
//    for (HYFileDownloadTask *willSaveItem in items) {
//        
//        [waitingCopy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//           
//            if ([[(HYFileDownloadTask *)obj urlStr] isEqualToString:willSaveItem.urlStr]) {
//                [removes addObject:obj];
//                *stop = YES;
//            }
//
//        }];
//    }
//    
//    [waitingCopy removeObjectsInArray:removes];
//    [waitingCopy addObjectsFromArray:items];
//    
//    [downloadDict setObject:waitingCopy forKey:key_downloaded];
//
//    [self saveAllItems];
//}
//
//+ (void)removeDownloadingItem:(NSArray *)items {
//
//    NSMutableArray *removes = [NSMutableArray array];   //将要移除的item
//
//    NSMutableArray *downloadingCopy = [downloadDict[key_downloading] mutableCopy];
//
//    if (!downloadingCopy) {
//        downloadingCopy = [NSMutableArray array];
//    }
//
//    for (HYFileDownloadTask *willSaveItem in items) {
//
//        [downloadingCopy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//            if ([[(HYFileDownloadTask *)obj urlStr] isEqualToString:willSaveItem.urlStr]) {
//                [removes addObject:obj];
//                *stop = YES;
//            }
//
//        }];
//    }
//
//    [downloadingCopy removeObjectsInArray:removes];
//
//    [downloadDict setObject:downloadingCopy forKey:key_downloading];
//}
//
//+ (void)removeWaitingItems:(NSArray *)items {
//    [[self allWaitingItems] removeObjectsInArray:items];
//}

@end

#pragma mark - HYFileDownloader ---------------------------------------

@interface HYFileDownloader () <NSURLSessionDelegate>

@property (strong, nonatomic) NSOperationQueue *queue ;
@property (strong, nonatomic) NSURLSession *session ;
@property (strong, nonatomic) NSMutableDictionary *identifierTaskDic ;  //key为taskidentifier，value为对应的task

/**
 *  下载中的任务
 */
@property (strong, nonatomic) NSMutableArray *downloadingTasks;

/**
 *  下载完成的任务
 */
@property (strong, nonatomic) NSMutableArray *downloadedTasks;


@end

#pragma mark - HYFileNoMoveDownloadTask -----------------------------

@implementation HYFileNoMoveDownloadTask

- (BOOL)isCacheInDownloader:(HYFileDownloader *)downloader {
    __block BOOL isCache = NO;
    [downloader.downloadedTasks enumerateObjectsUsingBlock:^(HYFileDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.urlStr isEqualToString:self.urlStr]) {
            isCache = YES;
            *stop = YES;
        }
    }];

    return isCache;
}

@end

#pragma mark - HYFileDownloader -----------------------------

@implementation HYFileDownloader

#pragma mark - LifeCycle

- (instancetype)init {
    if (self = [super init]) {
        self.maxDownloadCount = 10;
        [self loadAllItems];
    }

    return self;
}

#pragma mark - Message

+ (instancetype)defaultDownloader {
    static HYFileDownloader *downloader = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[HYFileDownloader alloc] init];
    });

    return downloader;
}

- (void)loadAllItems {

    if (!downloadDict) {

        downloadDict = [NSKeyedUnarchiver unarchiveObjectWithFile:[HYFileDownloadTask fileForDownload]];
        if (!downloadDict) {
            downloadDict = [NSMutableDictionary dictionary];
        }
        
    }

    for (HYFileDownloadTask *task in downloadDict[key_downloading]) {
        [self addTask:task];
    }

    self.downloadedTasks = downloadDict[key_downloaded];
}

- (void)addTask:(HYFileDownloadTask *)task {

    if (!task) {
        return;
    }

    [self renameTask:task];

    NSString *tempPath = [HYFileDownloader tempPathForFilePath:task];

    NSURL *url = [NSURL URLWithString:task.urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    long long downLoadBytes = task.currentLength;


    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", downLoadBytes];
        [request setValue:range forHTTPHeaderField:@"Range"];
    } else {
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", 0];
        [request setValue:range forHTTPHeaderField:@"Range"];

    }


    //方案1、可以使用NSURLConnection，获取data
    //    [NSURLConnection connectionWithRequest:request delegate:self];

    /*
     方案2、可以使用NSURLSessionDataTask来完成，获取data
     1、使用dataTaskWithRequest启动NSURLSessionDataTask，可以从代理获取data
     效果和用NSURLConnection一样，需要根据获取的data和需求手动去管理缓存，

     2、使用downloadTaskWithRequest启动NSURLSessionDownloadTask，可以从代理中获取下载进度，
     以及不需要手动管理缓存，NSURLSessionDownloadTask会直接把已下载完成的部分缓存到tmp文件夹
     */
    task.task = [self.session dataTaskWithRequest:request];
    [task resume];

    [self.downloadingTasks addObject:task];
    [self.identifierTaskDic setObject:task forKey:@(task.task.taskIdentifier).stringValue];
}


- (void)removeTask:(HYFileDownloadTask *)task {

    [task cancel];
    [self.downloadingTasks removeObject:task];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[HYFileDownloader tempPathForFilePath:task]]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[HYFileDownloader tempPathForFilePath:task] error:&error];
    }

}

#pragma mark - Setter && Getter

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }

    return _queue;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.queue];
    }
    
    return _session;
}

- (NSMutableDictionary *)identifierTaskDic {
    if (!_identifierTaskDic) {
        _identifierTaskDic = [NSMutableDictionary dictionary];
    }

    return _identifierTaskDic;
}

- (void)setMaxDownloadCount:(NSUInteger)maxDownloadCount {
    _maxDownloadCount = maxDownloadCount;

    self.session.delegateQueue.maxConcurrentOperationCount = _maxDownloadCount;
}

- (NSMutableArray<HYFileDownloadTask *> *)downloadingTasks {
    if (!_downloadingTasks) {
        _downloadingTasks = [NSMutableArray array];
    }

    return _downloadingTasks;
}

- (NSMutableArray<HYFileDownloadTask *> *)downloadedTasks {
    if (!_downloadedTasks) {
        _downloadedTasks = [NSMutableArray array];
    }

    return _downloadedTasks;
}

- (NSString *)suffix {
    return _suffix.length>0? _suffix:@".temp";
}

- (NSString *)cachePath {
    if (!_cachePath.length) {
        _cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    }

    return _cachePath;
}

#pragma mark - Private

+ (NSString *)tempPathForFilePath:(HYFileDownloadTask *)task {

    if ([task isKindOfClass:[HYFileNoMoveDownloadTask class]]) {
        return [self absolutePathForFilePath:task];
    }

    NSString *tempPath = [HYFileDownloader defaultDownloader].cachePath;
    tempPath = [tempPath stringByAppendingPathComponent:task.filePath];

    return [tempPath stringByAppendingString:[HYFileDownloader defaultDownloader].suffix];
}

+ (NSString *)absolutePathForFilePath:(HYFileDownloadTask *)task {
    NSString *path = [HYFileDownloader defaultDownloader].cachePath;
    return [path stringByAppendingPathComponent:task.filePath];
}

- (void)synchronize {

    downloadDict[key_downloading] = self.downloadingTasks ;
    downloadDict[key_downloaded] = self.downloadedTasks ;

    if (downloadDict) {
        [NSKeyedArchiver archiveRootObject:downloadDict toFile:[HYFileDownloadTask fileForDownload]];
    }
}

/**
 *  根据任务，是否重复下载确定是否需要重命名任务名
 */
- (void)renameTask:(HYFileDownloadTask *)task {

    NSMutableArray *allTaskes = [self.downloadingTasks mutableCopy];

    if (!allTaskes) {
        allTaskes = [NSMutableArray array];
    }

    [allTaskes addObjectsFromArray:self.downloadedTasks];



    [allTaskes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if ([[(HYFileDownloadTask *)obj urlStr] isEqualToString:task.urlStr]) {

            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *suffix = [dateFormatter stringFromDate:date];

            task.title = [task.title stringByAppendingString:suffix];

            if ([task.filePath rangeOfString:@"."].length) {
                task.filePath = [task.filePath stringByReplacingOccurrencesOfString:@"." withString:[suffix stringByAppendingString:@"."]];
            } else {
                task.filePath = [task.filePath stringByAppendingString:suffix];
            }

            *stop = YES;
        }

    }];
}

#pragma mark - NSURLConnectionDataDelegate

/*

//接收到服务器响应的时候调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

    HYFileDownloadTask *task = self.downloadingTasks.firstObject;


    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSLog(@"response类型不正确");
        return;
    }

    int64_t total = 0;      //总共文件大小
    int64_t unfinished = [[(NSHTTPURLResponse *)response allHeaderFields][@"Content-Length"] longLongValue];

    //如果response中不包含Content-Length，那么从Content-Range传输流的大小信息
    if (unfinished == 0) {
        NSString *content_Range = [(NSHTTPURLResponse *)response allHeaderFields][@"Content-Range"];
        total = [[content_Range componentsSeparatedByString:@"/"].lastObject longLongValue];
    } else {
        total = unfinished+task.currentLength;
    }

    task.contentLength = total;

    if (task.stream) {
        [task.stream close];
    }

    //利用NSOutputStream往filePath文件中写数据，若append参数为yes，则会写到文件尾部
    task.stream = [[NSOutputStream alloc] initToFileAtPath:[HYFileDownloader tempPathForFilePath:task.filePath ] append:YES];
    [task.stream open];
}

//接收到数据的时候调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

    [_stream write:data.bytes maxLength:data.length];

    HYFileDownloadTask *item = self.downloadingTasks.firstObject;

    double progress = 1.*item.currentLength/item.contentLength;


    dispatch_async(dispatch_get_main_queue(), ^{
        item.progressBlock(progress);
    });



    NSLog(@"data-->%zd", data.length);

}

//数据下载完毕的时候调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    HYFileDownloadTask *item = self.downloadingTasks.firstObject;

    NSError *fileError = nil;
    //判断文件是否存在，如存在先删除，在重命名
    if ([[NSFileManager defaultManager] fileExistsAtPath:[HYFileDownloader absolutePathForFilePath:item.filePath]]) {

        [[NSFileManager defaultManager] removeItemAtPath:[HYFileDownloader absolutePathForFilePath:item.filePath] error:&fileError];
        if (fileError) {
            NSLog(@"%@", fileError);
        }
    }

    //通过move的方式来重命名
    [[NSFileManager defaultManager] moveItemAtPath:[HYFileDownloader tempPathForFilePath:item.filePath] toPath:[HYFileDownloader absolutePathForFilePath:item.filePath] error:&fileError];
    if (fileError) {
        NSLog(@"%@", fileError);
    }

    [self.downloadingTasks removeObjectAtIndex:0];

//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self resume:self.downloadingTasks.firstObject];
//
//    }) ;
}

*/

#pragma mark - NSURLSessionDataDelegate



- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    HYFileDownloadTask *task = self.identifierTaskDic[@(dataTask.taskIdentifier).stringValue];


    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSLog(@"response类型不正确");
        return;
    }

    int64_t total = 0;      //总共文件大小
    int64_t unfinished = [[(NSHTTPURLResponse *)response allHeaderFields][@"Content-Length"] longLongValue];

    //如果response中不包含Content-Length，那么从Content-Range传输流的大小信息
    if (unfinished == 0) {
        NSString *content_Range = [(NSHTTPURLResponse *)response allHeaderFields][@"Content-Range"];
        total = [[content_Range componentsSeparatedByString:@"/"].lastObject longLongValue];
    } else {
        total = unfinished+task.currentLength;
    }

    task.contentLength = total;

    if (task.stream) {
        [task.stream close];
    }

    //利用NSOutputStream往filePath文件中写数据，若append参数为yes，则会写到文件尾部
    task.stream = [[NSOutputStream alloc] initToFileAtPath:[HYFileDownloader tempPathForFilePath:task ] append:YES];
    [task.stream open];
    completionHandler(NSURLSessionResponseAllow);

    NSLog(@"开始下载->%@", task.title);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    HYFileDownloadTask *task = self.identifierTaskDic[@(dataTask.taskIdentifier).stringValue];

    [task.stream write:data.bytes maxLength:data.length];

    HYFileDownloadTask *item = self.downloadingTasks.firstObject;

    double progress = 1.*item.currentLength/item.contentLength;


    dispatch_async(dispatch_get_main_queue(), ^{

        if (item.progressBlock) {
            item.progressBlock(item, progress);
        }
    });



    NSLog(@"data-->%zd", data.length);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {

    HYFileDownloadTask *downloadtask = self.identifierTaskDic[@(task.taskIdentifier).stringValue];

    [downloadtask.stream close];

    if (error) {
        NSLog(@"%@", error);
    } else {
        HYFileDownloadTask *downloadtask = self.identifierTaskDic[@(task.taskIdentifier).stringValue];

        if (!task) {
            return;
        }


        //根据缓存文件是否有后缀名，来判断是否需要重命名
        if ([downloadtask isKindOfClass:[HYFileNoMoveDownloadTask class]]) {

        } else {
            NSError *fileError = nil;
            //判断文件是否存在，如存在先删除，在重命名
            if ([[NSFileManager defaultManager] fileExistsAtPath:[HYFileDownloader absolutePathForFilePath:downloadtask]]) {

                [[NSFileManager defaultManager] removeItemAtPath:[HYFileDownloader absolutePathForFilePath:downloadtask] error:&fileError];
                if (fileError) {
                    NSLog(@"%@", fileError);
                }
            }

            //通过move的方式来重命名
            [[NSFileManager defaultManager] moveItemAtPath:[HYFileDownloader tempPathForFilePath:downloadtask] toPath:[HYFileDownloader absolutePathForFilePath:downloadtask] error:&fileError];
            if (fileError) {
                NSLog(@"%@", fileError);
            }
        }


        [self.identifierTaskDic removeObjectForKey:@(task.taskIdentifier).stringValue];

        dispatch_async(dispatch_get_main_queue(), ^{

            //防止主线程中，防止因异步操作导致异常
            [self.downloadingTasks removeObject:downloadtask];
            [self.downloadedTasks insertObject:downloadtask atIndex:0];

            [self synchronize];

            [[NSNotificationCenter defaultCenter] postNotificationName:HYFileDownloadTaskDidFinished object:nil];
        }) ;
    }
}

@end
