//
//  PooURLCache.m
//  WebCache
//
//  Created by crazypoo on 14-4-23.
//  Copyright (c) 2014年 crazypoo. All rights reserved.
//

#import "PooURLCache.h"

@interface PooURLCache(private)
- (NSString *)cacheFolder;
- (NSString *)cacheFilePath:(NSString *)file;
- (NSString *)cacheRequestFileName:(NSString *)requestUrl;
- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl;
- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request;
- (void)deleteCacheFolder;
@end

@implementation PooURLCache
@synthesize cacheTime          = _cacheTime;
@synthesize diskPath           = _diskPath;
@synthesize responseDictionary = _responseDictionary;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime
{
    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path])
    {
        self.cacheTime = cacheTime;
        if (path)
            self.diskPath = path;
        else
            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame)
    {
        return [super cachedResponseForRequest:request];
    }
    return [self dataFromRequest:request];
}

- (void)removeAllCachedResponses
{
    [super removeAllCachedResponses];
    [self deleteCacheFolder];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [super removeCachedResponseForRequest:request];
    
    NSString *url               = request.URL.absoluteString;
    NSString *fileName          = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath          = [self cacheFilePath:fileName];
    NSString *otherInfoPath     = [self cacheFilePath:otherInfoFileName];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:otherInfoPath error:nil];
}

#pragma mark ------ 自定義緩存
- (NSString *)cacheFolder
{
    return @"URLCACHE";
}

- (void)deleteCacheFolder
{
    NSString *path             = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)cacheFilePath:(NSString *)file
{
    NSString *path             = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir)
    {
    }
    else
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@", path, file];
}

- (NSString *)cacheRequestFileName:(NSString *)requestUrl
{
    return [PooUtil md5Hash:requestUrl];
}

- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl
{
    return [PooUtil md5Hash:[NSString stringWithFormat:@"%@-otherInfo", requestUrl]];
}

- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request
{
    NSString *url               = request.URL.absoluteString;
    NSString *fileName          = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath          = [self cacheFilePath:fileName];
    NSString *otherInfoPath     = [self cacheFilePath:otherInfoFileName];
    NSDate *date                = [NSDate date];

    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        BOOL expire = false;
        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
        if (self.cacheTime > 0)
        {
            NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
            if (createTime + self.cacheTime < [date timeIntervalSince1970])
            {
                expire = true;
            }
        }
        if (expire == false)
        {
            //TODO: 從緩存獲取數據
            NSLog(@"Push me.....");
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[otherInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            return cachedResponse;
        }
        else
        {
            //TODO:緩存time out
            [fileManager removeItemAtPath:filePath error:nil];
            [fileManager removeItemAtPath:otherInfoPath error:nil];
        }
    }
    
    __block NSCachedURLResponse *cachedResponse = nil;

    id boolExsite = [self.responseDictionary objectForKey:url];
    if (boolExsite == nil)
    {
        [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data,NSError *error)
         {
             [self.responseDictionary removeObjectForKey:url];
             
             if (error)
             {
                 //TODO: 錯誤提示
                 NSLog(@"%@",error);
                 NSLog(@"%@",request.URL.absoluteString);
                 cachedResponse = nil;
                 return;
             }
             
             //TODO: 獲取
             NSLog(@"Fuck me....");
             NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
                                   response.MIMEType, @"MIMEType",
                                   response.textEncodingName, @"textEncodingName", nil];
             [dict writeToFile:otherInfoPath atomically:YES];
             [data writeToFile:filePath atomically:YES];
             
             cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
             
         }];
        return cachedResponse;
    }
    return nil;
}

@end
