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

    NSString *const plainDBPath = [SQLCipherMigrator unencryptedDBPath];

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

    NSString *const plainDBPath = [SQLCipherMigrator unencryptedDBPath];

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

    NSString *const plainDBPath = [SQLCipherMigrator unencryptedDBPath];

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
