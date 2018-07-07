//
//  CompanyMaster.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSetInitializable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 company_masterテーブルのDTO
 */
@interface CompanyMaster : NSObject <FMResultSetInitializable>

@property (nonatomic) TableModel tableModel;
@property (nonatomic) NSUInteger companyNo;
@property (nonatomic) NSString *companyName;
@property (nonatomic) NSUInteger companyEmployeesCount;

- (instancetype)initWithCompanyNo:(NSUInteger)companyNo
                      companyName:(NSString *)companyName
            companyEmployeesCount:(NSUInteger)companyEmployeesCount;

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;
@end

NS_ASSUME_NONNULL_END
