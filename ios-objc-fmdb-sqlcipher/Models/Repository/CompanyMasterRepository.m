//
//  CompanyMasterRepository.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "CompanyMasterRepository.h"
#import "CompanyMasterTableCache.h"
#import "EncryptedDAO.h"
#import "SQLiteRequest.h"

@implementation CompanyMasterRepositoryImpl

#pragma mark - INSERT

- (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray error:(DataAccessError **)error {

    NSMutableArray <SQLiteRequest *> *insertRequests = [@[] mutableCopy];
    NSString *const sql = @"INSERT INTO company_master(company_name, company_employees_count) VALUES(?, ?);";

    for (CompanyMaster *companyMaster in newDataArray) {

        NSArray *parameters = @[companyMaster.companyName, @(companyMaster.companyEmployeesCount)];
        SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];
        [insertRequests addObject:request];
    }

    BOOL insertResult = [[EncryptedDAO shared] inTransaction:insertRequests.copy error:error];
    if (!insertResult) {
        return NO;
    }

    // キャッシュをアップデートする
    BOOL updateCachesResult = [self updateCachesWithError:error];
    return updateCachesResult;
}

#pragma mark - UPDATE

- (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray error:(DataAccessError **)error {

    NSMutableArray <SQLiteRequest *> *updateRequests = [@[] mutableCopy];
    NSString *const sql = @"UPDATE company_master SET company_name = ?, company_employees_count = ? WHERE company_no = ?;";

    for (CompanyMaster *companyMaster in updateDataArray) {

        NSArray *parameters = @[companyMaster.companyName, @(companyMaster.companyEmployeesCount), @(companyMaster.companyNo)];
        SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];
        [updateRequests addObject:request];
    }

    BOOL updateResult = [[EncryptedDAO shared] inTransaction:updateRequests error:error];
    if (!updateResult) {
        return NO;
    }

    // キャッシュをアップデートする
    BOOL updateCachesResult = [self updateCachesWithError:error];
    return updateCachesResult;
}

- (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount
                      error:(DataAccessError **)error {

    NSString *const sql = @"UPDATE company_master SET company_name = ?, company_employees_count = ? WHERE company_no = ?;";
    NSArray *const parameters = @[companyName, @(companyEmployeesCount), @(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];

    BOOL updateResult = [[EncryptedDAO shared] inTransaction:@[request] error:error];
    if (!updateResult) {
        return NO;
    }

    // キャッシュをアップデートする
    BOOL updateCachesResult = [self updateCachesWithError:error];
    return updateCachesResult;
}

#pragma mark - DELETE

- (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error {

    NSString *const sql = @"DELETE FROM company_master WHERE company_no = ?;";
    NSArray *const parameter = @[@(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameter];

    BOOL deleteResult = [[EncryptedDAO shared] inTransaction:@[request] error:error];
    if (!deleteResult) {
        return NO;
    }

    // キャッシュをアップデートする
    BOOL updateCachesResult = [self updateCachesWithError:error];
    return updateCachesResult;
}

- (BOOL)truncateWithError:(DataAccessError **)error {

    BOOL truncateResult = [[EncryptedDAO shared] truncateWithTableName:@"company_master" error:error];
    if (!truncateResult) {
        return NO;
    }

    // キャッシュをクリアする
    [[CompanyMasterTableCache shared] clearCache];
    return YES;
}

#pragma mark - SELECT (no cache.)

/**
 キャッシュに保存するレコードを取得する

 キャッシュを参照せず、必ずqueryを実行する

 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectAllNoCacheWithError:(DataAccessError **)error {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master;";

    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:nil];
    NSArray <NSDictionary *> *resultDics = [[EncryptedDAO shared] executeQuery:request error:error];

    NSMutableArray <CompanyMaster *> *results = [@[] mutableCopy];
    for (NSDictionary *resultDic in resultDics) {
        [results addObject:[[CompanyMaster alloc] initWithResultDictionary:resultDic]];
    }

    return results.copy;
}

#pragma mark - SELECT

- (NSArray <CompanyMaster *> *)selectAllWithError:(DataAccessError **)error {

    // キャッシュが存在する場合はキャッシュを使用する
    BOOL existCaches = [[CompanyMasterTableCache shared] existCaches];
    if (existCaches) {
        return [[CompanyMasterTableCache shared] readCachesWithPredicate:nil];
    }

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master;";

    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:nil];
    NSArray <NSDictionary *> *resultDics = [[EncryptedDAO shared] executeQuery:request error:error];

    NSMutableArray <CompanyMaster *> *results = [@[] mutableCopy];
    for (NSDictionary *resultDic in resultDics) {
        [results addObject:[[CompanyMaster alloc] initWithResultDictionary:resultDic]];
    }

    return results.copy;
}

- (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error {

    // キャッシュが存在する場合はキャッシュを使用する
    BOOL existCaches = [[CompanyMasterTableCache shared] existCaches];
    if (existCaches) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"companyNo", @(companyNo)];
        return [[CompanyMasterTableCache shared] readCachesWithPredicate:predicate];
    }

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master WHERE company_no = ?;";
    NSArray *const parameter = @[@(companyNo)];

    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameter];
    NSArray <NSDictionary *> *resultDics = [[EncryptedDAO shared] executeQuery:request error:error];

    NSMutableArray <CompanyMaster *> *results = [@[] mutableCopy];
    for (NSDictionary *resultDic in resultDics) {
        [results addObject:[[CompanyMaster alloc] initWithResultDictionary:resultDic]];
    }

    return results.copy;
}

- (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold error:(DataAccessError **)error {

    // キャッシュが存在する場合はキャッシュを使用する
    BOOL existCaches = [[CompanyMasterTableCache shared] existCaches];
    if (existCaches) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@", @"company_employees_count", @(threshold)];
        return [[CompanyMasterTableCache shared] readCachesWithPredicate:predicate];
    }

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master WHERE company_employees_count >= ?;";
    NSArray *const parameter = @[@(threshold)];

    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameter];
    NSArray <NSDictionary *> *resultDics = [[EncryptedDAO shared] executeQuery:request error:error];

    NSMutableArray <CompanyMaster *> *results = [@[] mutableCopy];
    for (NSDictionary *resultDic in resultDics) {
        [results addObject:[[CompanyMaster alloc] initWithResultDictionary:resultDic]];
    }

    return results.copy;
}

#pragma mark - Managed caches

- (BOOL)updateCachesWithError:(DataAccessError **)error {
    // キャッシュを更新するためのレコードを取得する
    NSArray <CompanyMaster *>*allRecords = [self selectAllNoCacheWithError:error];
    if (!allRecords) {
        return NO;
    }
    // キャッシュを更新する
    [[CompanyMasterTableCache shared] saveCachesWithSelectResults:allRecords];
    return YES;
}
@end
