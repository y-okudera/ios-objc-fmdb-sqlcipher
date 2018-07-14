//
//  CompanyMasterRepository.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyMaster.h"
#import "DataAccessError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CompanyMasterRepository <NSObject>

#pragma mark - INSERT

/**
 複数件INSERT

 @param newDataArray (NSArray <CompanyMaster *> *) INSERTする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray error:(DataAccessError **)error;

#pragma mark - UPDATE

/**
 複数件UPDATE

 @param updateDataArray (NSArray <CompanyMaster *> *) UPDATEする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray error:(DataAccessError **)error;

/**
 1件UPDATE

 @param companyNo (NSUInteger) 会社No
 @param companyName (NSString *) 会社名
 @param companyEmployeesCount (NSUInteger) 従業員数
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount
                      error:(DataAccessError **)error;

#pragma mark - DELETE

/**
 1件削除

 @param companyNo (NSUInteger) 削除する会社の会社No
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 全データ削除

 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithError:(DataAccessError **)error;

#pragma mark - SELECT

/**
 全件取得する

 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectAllWithError:(DataAccessError **)error;

/**
 company_noを指定してレコードを1件取得する

 @param companyNo (NSUInteger) 取得するレコードのcompany_no
 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 従業員数がxx以上のレコードを取得する

 @param threshold 閾値
 @param error エラーオブジェクト
 @return 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold error:(DataAccessError **)error;

@end

@interface CompanyMasterRepositoryImpl : NSObject <CompanyMasterRepository>

#pragma mark - INSERT

/**
 複数件INSERT

 @param newDataArray (NSArray <CompanyMaster *> *) INSERTする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray error:(DataAccessError **)error;

#pragma mark - UPDATE

/**
 複数件UPDATE

 @param updateDataArray (NSArray <CompanyMaster *> *) UPDATEする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray error:(DataAccessError **)error;

/**
 1件UPDATE

 @param companyNo (NSUInteger) 会社No
 @param companyName (NSString *) 会社名
 @param companyEmployeesCount (NSUInteger) 従業員数
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount
                      error:(DataAccessError **)error;

#pragma mark - DELETE

/**
 1件削除

 @param companyNo (NSUInteger) 削除する会社の会社No
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 全データ削除

 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithError:(DataAccessError **)error;

#pragma mark - SELECT

/**
 全件取得する

 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectAllWithError:(DataAccessError **)error;

/**
 company_noを指定してレコードを1件取得する

 @param companyNo (NSUInteger) 取得するレコードのcompany_no
 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 従業員数がxx以上のレコードを取得する

 @param threshold 閾値
 @param error エラーオブジェクト
 @return 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold error:(DataAccessError **)error;
@end

NS_ASSUME_NONNULL_END
