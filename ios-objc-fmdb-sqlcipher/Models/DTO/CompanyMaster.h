//
//  CompanyMaster.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBResultDictionaryInitializable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 company_masterテーブルのDTO
 */
@interface CompanyMaster : NSObject <FMDBResultDictionaryInitializable>

@property (nonatomic) NSUInteger companyNo;
@property (nonatomic) NSString *companyName;
@property (nonatomic) NSUInteger companyEmployeesCount;

- (instancetype)initWithCompanyNo:(NSUInteger)companyNo
                      companyName:(NSString *)companyName
            companyEmployeesCount:(NSUInteger)companyEmployeesCount;

- (instancetype)initWithResultDictionary:(NSDictionary *)resultDictionary;
@end

NS_ASSUME_NONNULL_END
