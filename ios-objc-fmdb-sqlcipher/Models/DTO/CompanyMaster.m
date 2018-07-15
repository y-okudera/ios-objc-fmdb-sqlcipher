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
        self.companyNo = companyNo;
        self.companyName = companyName;
        self.companyEmployeesCount = companyEmployeesCount;
    }
    return self;
}

- (instancetype)initWithResultDictionary:(NSDictionary *)resultDictionary {

    NSUInteger const companyNo = [resultDictionary[@"company_no"] unsignedIntegerValue];
    NSString *const companyName = [resultDictionary[@"company_name"] nullToNil];
    NSUInteger const companyEmployeesCount = [resultDictionary[@"company_employees_count"] unsignedIntegerValue];

    return [self initWithCompanyNo:companyNo companyName:companyName companyEmployeesCount:companyEmployeesCount];
}

@end
