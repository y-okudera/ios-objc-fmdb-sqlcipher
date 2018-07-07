//
//  CompanyMaster.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "CompanyMaster.h"

@implementation CompanyMaster

- (instancetype)initWithCompanyNo:(NSUInteger)companyNo
                      companyName:(NSString *)companyName
            companyEmployeesCount:(NSUInteger)companyEmployeesCount {

    self = [super init];
    if (self) {
        self.tableModel = TableModelCompanyMaster;
        self.companyNo = companyNo;
        self.companyName = companyName;
        self.companyEmployeesCount = companyEmployeesCount;
    }
    return self;
}

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet {

    NSUInteger const companyNo = [resultSet longForColumn:@"company_no"];
    NSString *const companyName = [[resultSet stringForColumn:@"company_name"] nullToNil];
    NSUInteger const companyEmployeesCount = [resultSet longForColumn:@"company_employees_count"];

    return [self initWithCompanyNo:companyNo companyName:companyName companyEmployeesCount:companyEmployeesCount];
}

@end
