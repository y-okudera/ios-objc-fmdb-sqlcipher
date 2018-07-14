//
//  EncryptedDAO.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessError.h"
#import "FMResultSetInitializable.h"
#import "SelectResult.h"
#import "SQLiteRequest.h"

extern NSString *_Nonnull const sqliteDBKey;

@interface EncryptedDAO : NSObject

+ (nonnull instancetype)shared;
+ (nonnull NSString *)dbPath;

#pragma mark - INSERT, UPDATE, DELETE

/**
 INSERT, UPDATE, DELETE

 @param requests (NSArray <SQLiteRequest *>*) queryとparametersの配列
 @param error (DataAccessError **) エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)inTransaction:(nonnull NSArray <SQLiteRequest *> *)requests
                error:(DataAccessError *_Nullable *_Nullable)error;

/**
 INSERT, UPDATE, DELETE

 @param dics (NSArray <NSDictionary *) queryとparametersの配列
 @param error (DataAccessError **) エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)inTransactionWithDictionaries:(nonnull NSArray <NSDictionary *> *)dics
                                error:(DataAccessError *_Nullable *_Nullable)error;

#pragma mark - SELECT

/**
 SELECT

 @param request (SQLiteRequest *) query・parameters
 @param selectResult (SelectResult *)結果を格納するオブジェクト
 @param error (DataAccessError **) エラーオブジェクト
 */
- (void)executeQuery:(nonnull SQLiteRequest *)request
              result:(nonnull SelectResult *)selectResult
               error:(DataAccessError *_Nullable *_Nullable)error;

#pragma mark - TRUNCATE

/**
 TRUNCATEと同等の処理を実行する

 @param tableName (NSString *) 対象のテーブル名
 @param error (DataAccessError **) エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithTableName:(nonnull NSString *)tableName error:(DataAccessError *_Nullable *_Nullable)error;

#pragma mark - Access sqlite_master

/**
 Table名を取得する

 @param error (DataAccessError **) エラーオブジェクト
 @return Table名の配列
 */
- (nonnull NSArray <NSString *> *)selectTableNamesWithError:(DataAccessError *_Nullable *_Nullable)error;

#pragma mark - Create dictionary

+ (nonnull NSDictionary <NSString *, id> *)createDictionaryForTransaction:(nonnull NSString *)query
                                                               parameters:(nullable NSArray *)parameters;

@end

