//
//  DBMigrationTests.m
//  ios-objc-fmdb-sqlcipherTests
//
//  Created by YukiOkudera on 2018/07/08.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CreatingTablesRepository.h"
#import "CompanyMasterRepository.h"
#import "EncryptedDAO.h"
#import "SQLCipherMigrator.h"

@interface DBMigrationTests : XCTestCase
@property (nonatomic) CompanyMasterRepositoryImpl *companyMasterRepository;
@end

@implementation DBMigrationTests

- (void)setUp {

    self.companyMasterRepository = [[CompanyMasterRepositoryImpl alloc] init];
}

/**
 非暗号化DB・暗号化DBともに存在しないケース
 */
- (void)testNotExistAnyDB {

    // setup
    [self removePlainDB];
    [self removeEncryptedDB];

    // 非暗号化DBをリソースからコピーする
    [self copyPlainDB];

    // 移行処理を実行する
    BOOL migrateResult = [[SQLCipherMigrator shared] migrateToEncryptedDB];

    XCTAssertTrue(migrateResult);
    XCTAssertTrue([self existsEncryptedDB]);
    XCTAssertFalse([self existsPlainDB]);

    // 移行後、正常に使用できることを確認する(負荷テストを流用)
    BOOL truncateResult = [self.companyMasterRepository truncate];
    if (truncateResult) {
        NSLog(@"company_masterテーブルTRUNCATE成功");
    } else {
        XCTFail(@"company_masterテーブルTRUNCATE失敗");
    }

    const int numberOfTrials = 10;
    const int operationsPerTransaction = 10;

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

            BOOL insertResult = [self.companyMasterRepository insertWithCompanyMasterArray:models];
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
                    CompanyMaster *updateModel = [[CompanyMaster alloc] initWithCompanyNo:i+k
                                                                              companyName:[NSString stringWithFormat:@"<UPDATE>株式会社%d-%d", i, k]
                                                                    companyEmployeesCount:1000];
                    [updateModels addObject:updateModel];
                }
            }

            BOOL resultOfUpdate = [self.companyMasterRepository updateWithCompanyMasterArray:updateModels];
            if (resultOfUpdate) {
                NSLog(@"i = %d UPDATE成功", i);
            } else {
                XCTFail(@"i = %d UPDATE失敗", i);
            }
        }
    }

    // SELECT
    NSArray <CompanyMaster *> *selectedData = [self.companyMasterRepository selectAll];
    XCTAssertEqual(selectedData.count, 100);
    XCTAssertEqualObjects(selectedData.firstObject.companyName, @"<UPDATE>株式会社1-0");
    XCTAssertEqual(selectedData.firstObject.companyEmployeesCount, 1000);
}

// TODO: - 非暗号化DBのみ存在する(レコード有り)

// TODO: - 暗号化DBのみ存在する(レコード有り)

// TODO: - 非暗号化DB・暗号化DBともに存在する(レコード有り)


/**
 plain.sqlite3がDocumentsディレクトリに存在するかどうか

 @return YES: 存在する, NO: 存在しない
 */
- (BOOL)existsPlainDB {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *const plainDBPath = [SQLCipherMigrator dbPath];

    return [fileManager fileExistsAtPath:plainDBPath];
}

/**
 encrypted.sqlite3がDocumentsディレクトリに存在するかどうか

 @return YES: 存在する, NO: 存在しない
 */
- (BOOL)existsEncryptedDB {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *const encryptedDB = [EncryptedDAO dbPath];

    return [fileManager fileExistsAtPath:encryptedDB];
}

/**
 plain.sqlite3がDocumentsディレクトリに存在しなければコピーする
 */
- (void)copyPlainDB {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *const plainDBPath = [SQLCipherMigrator dbPath];

    if (![fileManager fileExistsAtPath:plainDBPath]) {
        NSString *plainDBResourcePath = [NSBundle.mainBundle pathForResource:@"plain" ofType:@"sqlite3"];
        NSError *copyDBError = nil;
        BOOL copyResult = [fileManager copyItemAtPath:plainDBResourcePath
                                               toPath:plainDBPath
                                                error:&copyDBError];
        if (!copyResult) {
            XCTFail(@"[copyDBError] code: %ld description: %@", copyDBError.code, copyDBError.description);
        }
    }
}

/**
 plain.sqlite3がDocumentsディレクトリに存在したら、削除する
 */
- (void)removePlainDB {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *const plainDBPath = [SQLCipherMigrator dbPath];

    if ([fileManager fileExistsAtPath:plainDBPath]) {
        NSError *removeDBError = nil;
        BOOL removeResult = [fileManager removeItemAtPath:plainDBPath error:&removeDBError];

        if (!removeResult) {
            XCTFail(@"[removeDBError(PlainDB)] code: %ld description: %@", removeDBError.code, removeDBError.description);
        }
    }
}

/**
 encrypted.sqlite3がDocumentsディレクトリに存在したら、削除する
 */
- (void)removeEncryptedDB {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *const encryptedDB = [EncryptedDAO dbPath];

    if ([fileManager fileExistsAtPath:encryptedDB]) {
        NSError *removeDBError = nil;
        BOOL removeResult = [fileManager removeItemAtPath:encryptedDB error:&removeDBError];

        if (!removeResult) {
            XCTFail(@"[removeDBError(EncryptedDB)] code: %ld description: %@", removeDBError.code, removeDBError.description);
        }
    }
}
@end
