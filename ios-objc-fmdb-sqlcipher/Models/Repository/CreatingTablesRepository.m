//
//  CreatingTablesRepository.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "CreatingTablesRepository.h"
#import "EncryptedDAO.h"
#import "SQLiteRequest.h"

@implementation CreatingTablesRepositoryImpl

- (BOOL)createAllTables {

    NSMutableArray <SQLiteRequest *> *requestArray = [@[] mutableCopy];

    NSString *const createCompanyMaster = @"\
    CREATE TABLE IF NOT EXISTS `company_master` (\
    `company_no`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
    `company_name`    TEXT NOT NULL,\
    `company_employees_count`    INTEGER\
    )\
    ";
    
    [requestArray addObject:[[SQLiteRequest alloc] initWithQuery:createCompanyMaster parameters:nil]];
    
    NSString *const createJobMaster = @"\
    CREATE TABLE IF NOT EXISTS job_master (\
    `job_no`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
    `company_no`    INTEGER NOT NULL,\
    `posting_start_date`    TEXT NOT NULL,\
    `posting_end_date`    TEXT NOT NULL,\
    `job_title`    TEXT NOT NULL,\
    `job_image_url`    TEXT,\
    `job_location`    TEXT,\
    `job_interview_location`    TEXT,\
    `job_salary`    TEXT,\
    `job_detail_info`    TEXT\
    )\
    ";
    
    [requestArray addObject:[[SQLiteRequest alloc] initWithQuery:createJobMaster parameters:nil]];

    return [[EncryptedDAO shared] inTransaction:requestArray.copy];
}
@end
