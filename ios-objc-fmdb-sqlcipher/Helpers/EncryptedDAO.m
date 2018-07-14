//
//  EncryptedDAO.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import "FMDatabaseQueue.h"
#import "EncryptedDAO.h"

@interface EncryptedDAO ()

@property (nonatomic) FMDatabase *fmdb;
@property (nonatomic) NSLock *lock;
@end

static NSString *const sqliteDBName = @"encrypted.sqlite3";
NSString *const sqliteDBKey = @"zaq12wsxcde34rfvbgt56yhnmju78ik,";

@implementation EncryptedDAO

#pragma mark - Singleton

+ (instancetype)shared {

    static EncryptedDAO *encryptedDAO = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encryptedDAO = [[self alloc] init];
    });
    return encryptedDAO;
}

#pragma mark - Database path

+ (NSString *)dbPath {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES).firstObject;
    return [documentsDirectory stringByAppendingPathComponent:sqliteDBName];
}

#pragma mark - Init

- (instancetype)init {

    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];

        NSString *dbPath = [[self class] dbPath];
        self.fmdb = [[FMDatabase alloc] initWithPath:dbPath];
        NSLog(@"DB PATH: %@", dbPath);
    }
    return self;
}

#pragma mark - Open and close database

/**
 open処理

 @return YES:: 成功, NO: 失敗
 */
- (BOOL)open {

    NSLog(@"%s", __func__);

    // ロックする
    [self.lock lock];
    NSLog(@"lock");

    NSLog(@"open開始");
    BOOL resultOfDBOpen = [self.fmdb open];
    NSLog(@"open終了");

    if (!resultOfDBOpen) {
        NSLog(@"open失敗");
        return NO;
    }

    return YES;
}

/**
 open + setKey処理

 @return YES: 成功, NO: 失敗
 */
- (BOOL)openAndSettingKey {

    BOOL resultOfDBOpen = [self open];

    if (!resultOfDBOpen) {
        return NO;
    }

    // SQLCipher暗号化キーをセット
    BOOL resultOfSettingKey = [self.fmdb setKey:sqliteDBKey];

    if (!resultOfSettingKey) {
        NSLog(@"setKey: 失敗");
        return NO;
    }

    return YES;
}

/**
 close処理

 @return YES:: 成功, NO: 失敗
 */
- (BOOL)close {

    NSLog(@"%s", __func__);

    NSLog(@"close開始");
    BOOL closeResult = [self.fmdb close];
    NSLog(@"close終了");

    // ロックを解除する
    [self unlock];

    return closeResult;
}

#pragma mark - FMDatabaseQueue

/**
 INSERT, UPDATE, DELETE

 @param requests (NSArray <SQLiteRequest *>*) queryとparametersの配列
 @return result (BOOL *) 結果 YES: 成功, NO: 失敗
 */
- (BOOL)inTransaction:(NSArray <SQLiteRequest *> *)requests {

    BOOL resultOfDBOpen = [self open];

    if (!resultOfDBOpen) {

        [self outputErrorInfo];

        // ロックを解除する
        [self unlock];

        return NO;
    }

    __block BOOL result = YES;

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[[self class] dbPath]];
    [queue inDatabase:^(FMDatabase *db) {
        // SQLCipher暗号化キーをセット
        result = [db setKey:sqliteDBKey];
        if (!result) {

            NSLog(@"setKey失敗");

            int lastErrorCode = [db lastErrorCode];
            NSString *lastErrorMessage = [db lastErrorMessage];
            NSLog(@"lastErrorCode: %d, lastErrorMessage: %@", lastErrorCode, lastErrorMessage);
        }
    }];

    if (!result) {
        [self close];
        return NO;
    }

    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {

        result = YES;

        for (SQLiteRequest *sqliteRequest in requests) {

            result = [db executeUpdate:sqliteRequest.query withArgumentsInArray:sqliteRequest.parameters];

            if (!result) {

                NSLog(@"executeUpdate: withArgumentsInArray: 失敗");
                [self outputErrorInfo];

                *rollback = YES;
                break;
            }
        }
    }];

    result = [self close];

    if (!result) {
        NSLog(@"close失敗");
    }

    return result;
}

/**
 INSERT, UPDATE, DELETE

 @param dics (NSArray <NSDictionary *) queryとparametersの配列
 @return YES: 成功, NO: 失敗
 */
- (BOOL)inTransactionWithDictionaries:(NSArray <NSDictionary *> *)dics {

    BOOL resultOfDBOpen = [self open];

    if (!resultOfDBOpen) {

        [self outputErrorInfo];

        // ロックを解除する
        [self unlock];

        return NO;
    }

    __block BOOL result = YES;

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[[self class] dbPath]];
    [queue inDatabase:^(FMDatabase *db) {
        // SQLCipher暗号化キーをセット
        result = [db setKey:sqliteDBKey];
        if (!result) {

            NSLog(@"setKey失敗");

            int lastErrorCode = [db lastErrorCode];
            NSString *lastErrorMessage = [db lastErrorMessage];
            NSLog(@"lastErrorCode: %d, lastErrorMessage: %@", lastErrorCode, lastErrorMessage);
        }
    }];

    if (!result) {
        [self close];
        return NO;
    }

    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {

        result = YES;

        for (NSDictionary *dic in dics) {

            NSString *query = dic[dictionaryKeyQuery];
            NSArray *parameters = dic[dictionaryKeyParameters];
            result = [db executeUpdate:query withArgumentsInArray:parameters];

            if (!result) {

                NSLog(@"executeUpdate: withArgumentsInArray: 失敗");
                [self outputErrorInfo];

                *rollback = YES;
                break;
            }
        }
    }];

    result = [self close];

    if (!result) {
        NSLog(@"close失敗");
    }

    return result;
}

#pragma mark - Execute queries

/**
 SELECT
 @param request (SQLiteRequest *) query・parameters
 @param selectResult (SelectResult *)結果を格納するオブジェクト
 */
- (void)executeQuery:(SQLiteRequest *)request result:(SelectResult *)selectResult {

    if (request.tableModel != selectResult.tableModel) {
        NSLog(@"結果を格納するオブジェクトのTableModel不正");
        return;
    }

    [selectResult.resultArray removeAllObjects];

    BOOL resultOfDBOpen = [self openAndSettingKey];

    if (!resultOfDBOpen) {

        [self outputErrorInfo];

        // ロックを解除する
        [self unlock];
        return;
    }

    FMResultSet *executeResults = [self.fmdb executeQuery:request.query withArgumentsInArray:request.parameters];

    if (!executeResults) {

        NSLog(@"executeQuery: withArgumentsInArray: 失敗");
        [self outputErrorInfo];
    } else {

        while ([executeResults next]) {
            @autoreleasepool {
                [selectResult.resultArray addObject:[[selectResult.resultType.class alloc] initWithFMResultSet:executeResults]];
            }
        }
    }

    [executeResults close];

    [self close];
}

#pragma mark - TRUNCATE

/**
 TRUNCATEと同等の処理を実行する

 @param tableName (NSString *) 対象のテーブル名
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithTableName:(NSString *)tableName {

    NSMutableArray <NSDictionary *> *dics = [@[] mutableCopy];

    NSString *deleteRecords = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    [dics addObject:[EncryptedDAO createDictionaryForTransaction:deleteRecords
                                                      parameters:nil]];
    NSString *deleteRecordInSqliteSequence = [NSString stringWithFormat:@"DELETE FROM sqlite_sequence WHERE name = '%@';", tableName];
    [dics addObject:[EncryptedDAO createDictionaryForTransaction:deleteRecordInSqliteSequence
                                                      parameters:nil]];
    return [self inTransactionWithDictionaries:dics];
}

#pragma mark - Access sqlite_master

/**
 Table名を取得する

 @return Table名の配列
 */
- (NSArray <NSString *> *)selectTableNames {

    BOOL resultOfDBOpen = [self openAndSettingKey];

    if (!resultOfDBOpen) {

        [self outputErrorInfo];

        // ロックを解除する
        [self unlock];
        return @[];
    }

    FMResultSet *executeResults = [self.fmdb executeQuery:@"SELECT name FROM sqlite_master;"];
    NSMutableArray <NSString *> *results = [@[] mutableCopy];
    if (!executeResults) {

        NSLog(@"executeQuery: withArgumentsInArray: 失敗");
        [self outputErrorInfo];
    } else {

        while ([executeResults next]) {
            @autoreleasepool {
                [results addObject:[[executeResults stringForColumn:@"name"] nullToNil]];
            }
        }
    }

    [executeResults close];
    [self close];

    return results.copy;
}

#pragma mark - Create dictionary

static NSString *const dictionaryKeyQuery = @"query";
static NSString *const dictionaryKeyParameters = @"parameters";

+ (NSDictionary *)createDictionaryForTransaction:(NSString *)query
                                      parameters:(NSArray *)parameters {

    NSArray *notNilParams = parameters ? parameters : @[];
    return @{dictionaryKeyQuery : query,
             dictionaryKeyParameters : notNilParams};
}

#pragma mark - Private

/**
 ロックを解除する
 */
- (void)unlock {
    // ロックを解除する
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
