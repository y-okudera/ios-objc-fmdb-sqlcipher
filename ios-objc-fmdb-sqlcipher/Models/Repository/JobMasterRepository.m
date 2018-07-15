//
//  JobMasterRepository.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/15.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "JobMasterRepository.h"
#import "EncryptedDAO.h"
#import "SQLiteRequest.h"

@implementation JobMasterRepositoryImpl

#pragma mark - SELECT

/**
 掲載終了日が早い順で全件取得する

 @param error エラーオブジェクト
 @return (NSArray <JobMaster *> *) 取得結果
 */
- (NSArray <JobMaster *> *)selectAllSortedByPostingDateWithError:(DataAccessError **)error {
    
    NSString *const sql = @"\
    SELECT\
    j.job_no,\
    j.company_no,\
    j.posting_start_date,\
    j.posting_end_date,\
    j.job_title,\
    j.job_image_url,\
    j.job_location,\
    j.job_interview_location,\
    j.job_salary,\
    j.job_detail_info,\
    c.company_name\
    FROM job_master j\
    INNER JOIN company_master c ON\
    j.company_no = c.company_no\
    ORDER BY posting_end_date ASC;";

    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:nil];
    NSArray <NSDictionary *> *resultDics = [[EncryptedDAO shared] executeQuery:request error:error];

    NSMutableArray <JobMaster *> *results = [@[] mutableCopy];
    for (NSDictionary *resultDic in resultDics) {
        [results addObject:[[JobMaster alloc] initWithResultDictionary:resultDic]];
    }

    return results.copy;
}

/**
 新着順で全件取得する

 @param error エラーオブジェクト
 @return (NSArray <JobMaster *> *) 取得結果
 */
- (NSArray <JobMaster *> *)selectAllSortedByNewArrivalOrderWithError:(DataAccessError **)error {

    NSString *const sql = @"\
    SELECT\
    j.job_no,\
    j.company_no,\
    j.posting_start_date,\
    j.posting_end_date,\
    j.job_title,\
    j.job_image_url,\
    j.job_location,\
    j.job_interview_location,\
    j.job_salary,\
    j.job_detail_info,\
    c.company_name\
    FROM job_master j\
    INNER JOIN company_master c ON\
    j.company_no = c.company_no\
    ORDER BY posting_start_date ASC;";

    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:nil];
    NSArray <NSDictionary *> *resultDics = [[EncryptedDAO shared] executeQuery:request error:error];

    NSMutableArray <JobMaster *> *results = [@[] mutableCopy];
    for (NSDictionary *resultDic in resultDics) {
        [results addObject:[[JobMaster alloc] initWithResultDictionary:resultDic]];
    }

    return results.copy;
}

@end
