//
//  SQLiteRequest.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "SQLiteRequest.h"

@implementation SQLiteRequest

- (instancetype)initWithQuery:(NSString *)query parameters:(NSArray *)parameters tableModel:(TableModel)tableModel {

    self = [super init];
    if (self) {
        self.query = query;
        self.parameters = parameters;
        self.tableModel = tableModel;
    }
    return self;
}

- (instancetype)initWithQuery:(NSString *)query parameters:(NSArray *)parameters {
    return [self initWithQuery:query parameters:parameters tableModel:TableModelNone];
}
@end
