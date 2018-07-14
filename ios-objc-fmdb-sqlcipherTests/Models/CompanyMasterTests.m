//
//  CompanyMasterTests.m
//  ios-objc-fmdb-sqlcipherTests
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CompanyMasterRepository.h"
#import "CreatingTablesRepository.h"

@interface CompanyMasterTests : XCTestCase
@property (nonatomic) CompanyMasterRepositoryImpl *companyMasterRepository;
@end

@implementation CompanyMasterTests

- (void)setUp {

    CreatingTablesRepositoryImpl *creatingTablesRepository = [[CreatingTablesRepositoryImpl alloc] init];
    DataAccessError *error = nil;
    BOOL createSuccess = [creatingTablesRepository createAllTablesWithError:&error];
    if (createSuccess) {
        NSLog(@"Table 作成成功");
    } else {
        NSLog(@"%ld", error.error.code);
        NSLog(@"%@", error.error.userInfo);
        XCTFail(@"Table 作成失敗");
    }

    error = nil;
    self.companyMasterRepository = [[CompanyMasterRepositoryImpl alloc] init];
    BOOL truncateResult = [self.companyMasterRepository truncateWithError:&error];
    if (truncateResult) {
        NSLog(@"company_masterテーブルTRUNCATE成功");
    } else {
        NSLog(@"%ld", error.error.code);
        NSLog(@"%@", error.error.userInfo);
        XCTFail(@"company_masterテーブルTRUNCATE失敗");
    }
}

/**
 * 負荷テスト
 *
 * 1. 以下を1,000ループ
 *
 * - 1トランザクションでINSERT文を10件
 *
 * - 1トランザクションでUPDATE文を10件
 *
 * 2. 以下を1,000ループ
 *
 * - 1件SELECT
 *
 * - SELECTしたレコードをDELETE
 */
- (void)testOfStress {

    const int numberOfTrials = 10;
    const int operationsPerTransaction = 10;

    DataAccessError *error = nil;

    // INSERT -> UPDATE
    for (int i = 0; i < numberOfTrials; i++) {

        NSMutableArray <CompanyMaster *> *models = [@[] mutableCopy];
        @autoreleasepool {
            for (int j = 0; j < operationsPerTransaction; j++) {

                @autoreleasepool {
                    CompanyMaster *model = [[CompanyMaster alloc] initWithCompanyNo:i+j
                                                                        companyName:[NSString stringWithFormat:@"株式会社%d-%d", i, j]
                                                              companyEmployeesCount:300];
                    [models addObject:model];
                }
            }

            error = nil;
            BOOL insertResult = [self.companyMasterRepository insertWithCompanyMasterArray:models error:&error];
            if (insertResult) {
                NSLog(@"i = %d INSERT成功", i);
            } else {
                NSLog(@"%ld", error.error.code);
                NSLog(@"%@", error.error.userInfo);
                XCTFail(@"i = %d INSERT失敗", i);
            }
        }

        NSMutableArray <CompanyMaster *> *updateModels = [@[] mutableCopy];
        @autoreleasepool {
            for (int k = 0; k < operationsPerTransaction; k++) {

                @autoreleasepool {
                    CompanyMaster *updateModel = [[CompanyMaster alloc] initWithCompanyNo:i+k
                                                                        companyName:[NSString stringWithFormat:@"<UPDATE>株式会社%d-%d", i, k]
                                                              companyEmployeesCount:1000];
                    [updateModels addObject:updateModel];
                }
            }

            error = nil;
            BOOL resultOfUpdate = [self.companyMasterRepository updateWithCompanyMasterArray:updateModels error:&error];
            if (resultOfUpdate) {
                NSLog(@"i = %d UPDATE成功", i);
            } else {
                NSLog(@"%ld", error.error.code);
                NSLog(@"%@", error.error.userInfo);
                XCTFail(@"i = %d UPDATE失敗", i);
            }
        }
    }

    // SELECT -> DELETE
    for (int i = 1; i <= numberOfTrials * operationsPerTransaction; i++) {

        @autoreleasepool {
            error = nil;
            CompanyMaster *selectedData = [self.companyMasterRepository selectByCompanyNo:i error:&error].firstObject;
            if (selectedData) {
                NSLog(@"i = %d SELECT成功", i);

                error = nil;
                BOOL resultOfDelete = [self.companyMasterRepository deleteWithCompanyNo:i error:&error];
                if (resultOfDelete) {
                    NSLog(@"i = %d DELETE成功", i);
                } else {
                    NSLog(@"%ld", error.error.code);
                    NSLog(@"%@", error.error.userInfo);
                    XCTFail(@"i = %d DELETE失敗", i);
                }
            } else {
                NSLog(@"SELECT結果がnil");
                NSLog(@"%ld", error.error.code);
                NSLog(@"%@", error.error.userInfo);
                XCTFail(@"i = %d SELECT失敗", i);
            }
        }
    }
}
@end
