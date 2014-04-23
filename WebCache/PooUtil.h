//
//  PooUtil.h
//  WebCache
//
//  Created by crazypoo on 14-4-23.
//  Copyright (c) 2014年 crazypoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PooUtil : NSObject
+ (NSString *)sha1:(NSString *)str;
+ (NSString *)md5Hash:(NSString *)str;
@end
