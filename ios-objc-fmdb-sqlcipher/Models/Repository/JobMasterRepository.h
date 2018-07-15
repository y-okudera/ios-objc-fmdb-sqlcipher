//
//  JobMasterRepository.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/15.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessError.h"
#import "JobMaster.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JobMasterRepository <NSObject>

#pragma mark - SELECT

/**
 掲載終了日が早い順で全件取得する

 @param error エラーオブジェクト
 @return (NSArray <JobMaster *> *) 取得結果
 */
- (NSArray <JobMaster *> *)selectAllSortedByPostingDateWithError:(DataAccessError **)error;

/**
 新着順で全件取得する

 @param error エラーオブジェクト
 @return (NSArray <JobMaster *> *) 取得結果
 */
- (NSArray <JobMaster *> *)selectAllSortedByNewArrivalOrderWithError:(DataAccessError **)error;

@end

@interface JobMasterRepositoryImpl : NSObject <JobMasterRepository>

#pragma mark - SELECT

/**
 掲載終了日が早い順で全件取得する

 @param error エラーオブジェクト
 @return (NSArray <JobMaster *> *) 取得結果
 */
- (NSArray <JobMaster *> *)selectAllSortedByPostingDateWithError:(DataAccessError **)error;

/**
 新着順で全件取得する

 @param error エラーオブジェクト
 @return (NSArray <JobMaster *> *) 取得結果
 */
- (NSArray <JobMaster *> *)selectAllSortedByNewArrivalOrderWithError:(DataAccessError **)error;
@end

NS_ASSUME_NONNULL_END
