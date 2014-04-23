//
//  PooURLCache.h
//  WebCache
//
//  Created by crazypoo on 14-4-23.
//  Copyright (c) 2014年 crazypoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PooUtil.h"

@interface PooURLCache : NSURLCache
@property(nonatomic, assign) NSInteger cacheTime;
@property(nonatomic, retain) NSString *diskPath;
@property(nonatomic, retain) NSMutableDictionary *responseDictionary;
- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime;
@end
