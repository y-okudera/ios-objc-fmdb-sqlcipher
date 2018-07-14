//
//  SelectResult.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "SelectResult.h"

@interface SelectResult ()

@property (nonatomic, readwrite) TableModel tableModel;
@property (nonatomic, readwrite) __kindof NSObject <FMResultSetInitializable> * resultType;
@end

@implementation SelectResult

- (instancetype)initWithTableModel:(TableModel)tableModel
                        resultType:(__kindof NSObject<FMResultSetInitializable> *)resultType {

    self = [super init];
    if (self) {
        self.tableModel = tableModel;
        self.resultArray = [@[] mutableCopy];
        self.resultType = resultType;
    }
    return self;
}
@end
