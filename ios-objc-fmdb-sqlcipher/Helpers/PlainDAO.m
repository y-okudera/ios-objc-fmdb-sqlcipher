//
//  PlainDAO.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import "EncryptedDAO.h"
#import "PlainDAO.h"

@interface PlainDAO ()

@property (nonatomic) FMDatabase *fmdb;
@property (nonatomic) NSLock *lock;
@end

NSString *const sqlitePlainDBName = @"plain.sqlite3";

@implementation PlainDAO

#pragma mark - Singleton

+ (instancetype)shared {

    static PlainDAO *plainDAO = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        plainDAO = [[self alloc] init];
    });
    return plainDAO;
}

#pragma mark - Database path

+ (NSString *)dbPath {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES).firstObject;
    return [documentsDirectory stringByAppendingPathComponent:sqlitePlainDBName];
}

#pragma mark - Init

- (instancetype)init {

    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        self.fmdb = [[FMDatabase alloc] initWithPath:[[self class] dbPath]];
    }
    return self;
}

#pragma mark - Encrypt a plain text database

- (BOOL)migrateToEncryptedDB {

    __block BOOL result = YES;

    // ロックする
    [self startLock];

    BOOL resultOfEncryptedDBRemove = [self removeEncryptedDB];
    if (!resultOfEncryptedDBRemove) {
        NSLog(@"暗号化済みのDB削除失敗");

        // ロックを解除する
        [self endLock];
        return NO;
    }

    NSLog(@"open開始");
    BOOL resultOfDBOpen = [self.fmdb open];
    NSLog(@"open終了");

    if (!resultOfDBOpen) {

        [self outputErrorInfo];

        // ロックを解除する
        [self endLock];
        return NO;
    }

    NSArray <NSString *> *queries = @[
                                      [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", [EncryptedDAO dbPath], sqliteDBKey],
                                      @"SELECT sqlcipher_export('encrypted');",
                                      @"DETACH DATABASE encrypted;"
                                      ];

    for (NSString *query in queries) {

        if ([query hasPrefix:@"SELECT"]) {
            [self.fmdb executeQuery:query];
        } else {
            result = [self.fmdb executeUpdate:query];
        }

        if (!result || [self.fmdb hadError]) {
            [self outputErrorInfo];
            break;
        }
    }

    NSLog(@"close開始");
    [self.fmdb close];
    NSLog(@"close終了");

    NSError *removeDBError = nil;
    BOOL removeResult = [[NSFileManager defaultManager] removeItemAtPath:[[self class] dbPath]
                                                                   error:&removeDBError];
    if (!removeResult) {
        NSLog(@"[removeDBError] code: %ld, description: %@", removeDBError.code, removeDBError.description);
        // ロックを解除する
        [self endLock];
        return NO;
    }

    // ロックを解除する
    [self endLock];

    return result;
}

#pragma mark - Private

/**
 encrypted.sqlite3がDocumentsディレクトリに存在したら、削除する

 @return YES: 存在しない or 削除成功, NO: 削除失敗
 */
- (BOOL)removeEncryptedDB {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *const encryptedDB = [EncryptedDAO dbPath];

    if ([fileManager fileExistsAtPath:encryptedDB]) {

        NSError *removeDBError = nil;
        BOOL removeResult = [fileManager removeItemAtPath:encryptedDB error:&removeDBError];

        if (!removeResult) {

            NSLog(@"[removeDBError] code: %ld description: %@", removeDBError.code, removeDBError.description);
            return NO;
        }
    }
    return YES;
}

/**
 ロックを開始する
 */
- (void)startLock {

    [self.lock lock];
    NSLog(@"lock");
}

/**
 ロックを解除する
 */
- (void)endLock {

    [self.lock unlock];
    NSLog(@"unlock");
}

/**
 エラー情報をコンソールに出力する
 */
- (void)outputErrorInfo {

    const int lastErrorCode = [self.fmdb lastErrorCode];
    NSString *const lastErrorMessage = [self.fmdb lastErrorMessage];
    NSLog(@"lastErrorCode: %d, lastErrorMessage: %@", lastErrorCode, lastErrorMessage);
}
@end
