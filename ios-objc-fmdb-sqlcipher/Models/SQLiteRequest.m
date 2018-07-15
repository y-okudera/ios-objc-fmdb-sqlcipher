//
//  SQLiteRequest.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "SQLiteRequest.h"

@implementation SQLiteRequest

- (instancetype)initWithQuery:(NSString *)query parameters:(NSArray *)parameters {

    self = [super init];
    if (self) {
        self.query = query;
        self.parameters = parameters;
    }
    return self;
}

@end
