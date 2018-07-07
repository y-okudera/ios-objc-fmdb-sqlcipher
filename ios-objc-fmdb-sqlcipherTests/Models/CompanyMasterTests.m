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

@end

@implementation CompanyMasterTests

- (void)setUp {

    BOOL createSuccess = [CreatingTablesRepository createAllTables];
    if (createSuccess) {
        NSLog(@"Table 作成成功");
    } else {
        XCTFail(@"Table 作成失敗");
    }
    
    BOOL truncateResult = [CompanyMasterRepository truncate];
    if (truncateResult) {
        NSLog(@"company_masterテーブルTRUNCATE成功");
    } else {
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

    const int numberOfTrials = 1000;
    const int operationsPerTransaction = 10;

    // INSERT -> UPDATE
    for (int i = 0; i < numberOfTrials; i++) {

        NSMutableArray <CompanyMaster *> *models = [@[] mutableCopy];
        @autoreleasepool {
            for (int j = 0; j < operationsPerTransaction; j++) {

                @autoreleasepool {
                    CompanyMaster *model = [[CompanyMaster alloc] initWithCompanyNo:(i+j)
                                                                        companyName:[NSString stringWithFormat:@"株式会社%d-%d", i, j]
                                                              companyEmployeesCount:300];
                    [models addObject:model];
                }
            }

            BOOL insertResult = [CompanyMasterRepository insertWithCompanyMasterArray:models];
            if (insertResult) {
                NSLog(@"i = %d INSERT成功", i);
            } else {
                XCTFail(@"i = %d INSERT失敗", i);
            }
        }

        NSMutableArray <CompanyMaster *> *updateModels = [@[] mutableCopy];
        @autoreleasepool {
            for (int k = 0; k < operationsPerTransaction; k++) {

                @autoreleasepool {
                    CompanyMaster *updateModel = [[CompanyMaster alloc] initWithCompanyNo:(i+k)
                                                                        companyName:[NSString stringWithFormat:@"<UPDATE>株式会社%d-%d", i, k]
                                                              companyEmployeesCount:1000];
                    [updateModels addObject:updateModel];
                }
            }

            BOOL resultOfUpdate = [CompanyMasterRepository updateWithCompanyMasterArray:updateModels];
            if (resultOfUpdate) {
                NSLog(@"i = %d UPDATE成功", i);
            } else {
                XCTFail(@"i = %d UPDATE失敗", i);
            }
        }
    }

    // SELECT -> DELETE
    for (int i = 1; i <= numberOfTrials * operationsPerTransaction; i++) {

        @autoreleasepool {
            CompanyMaster *selectedData = [CompanyMasterRepository selectByCompanyNo:i].firstObject;
            if (selectedData) {
                NSLog(@"i = %d SELECT成功", i);

                BOOL resultOfDelete = [CompanyMasterRepository deleteWithCompanyNo:i];
                if (resultOfDelete) {
                    NSLog(@"i = %d DELETE成功", i);
                } else {
                    XCTFail(@"i = %d DELETE失敗", i);
                }
            } else {
                NSLog(@"SELECT結果がnil");
                XCTFail(@"i = %d SELECT失敗", i);
            }
        }
    }
}
@end
