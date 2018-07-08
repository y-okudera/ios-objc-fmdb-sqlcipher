//
//  EncryptedDAO.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSetInitializable.h"
#import "SelectResult.h"
#import "SQLiteRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface EncryptedDAO : NSObject

extern NSString *const sqliteDBKey;

+ (instancetype)shared;
+ (NSString *)dbPath;

#pragma mark - INSERT, UPDATE, DELETE
/**
 INSERT, UPDATE, DELETE

 @param requests (NSArray <SQLiteRequest *>*) queryとparametersの配列
 @return result (BOOL *) 結果 YES: 成功, NO: 失敗
 */
- (BOOL)inTransaction:(NSArray <SQLiteRequest *> *)requests;

/**
 INSERT, UPDATE, DELETE

 @param dics (NSArray <NSDictionary <NSString *, id> *> *) queryとparametersの配列
 @return YES: 成功, NO: 失敗
 */
- (BOOL)inTransactionWithDictionaries:(NSArray <NSDictionary <NSString *, id> *> *)dics;

#pragma mark - SELECT
/**
 SELECT
 @param request (SQLiteRequest *) query・parameters
 @param selectResult (SelectResult *)結果を格納するオブジェクト
 */
- (void)executeQuery:(SQLiteRequest *)request result:(SelectResult *)selectResult;

#pragma mark - TRUNCATE

/**
 TRUNCATEと同等の処理を実行する

 @param tableName (NSString *) 対象のテーブル名
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithTableName:(NSString *)tableName;

#pragma mark - Access sqlite_master

/**
 Table名を取得する

 @return Table名の配列
 */
- (NSArray <NSString *> *)selectTableNames;

NS_ASSUME_NONNULL_END

#pragma mark - Create dictionary

+ (nonnull NSDictionary <NSString *, id> *)createDictionaryForTransactionProcessing:(nonnull NSString *)query
                                                                         parameters:(nullable NSArray *)parameters;

@end

