//
//  JobMaster.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSetInitializable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 job_masterテーブルのDTO
 */
@interface JobMaster : NSObject <FMResultSetInitializable>

@property (nonatomic) TableModel tableModel;
@property (nonatomic) NSUInteger jobNo;
@property (nonatomic) NSUInteger companyNo;
@property (nonatomic) NSString *postingStartDate;
@property (nonatomic) NSString *postingEndDate;
@property (nonatomic) NSString *jobTitle;
@property (nonatomic) NSString *jobImageUrl;
@property (nonatomic) NSString *jobLocation;
@property (nonatomic) NSString *jobInterviewLocation;
@property (nonatomic) NSString *jobSalary;
@property (nonatomic) NSString *jobDetailInfo;

- (instancetype)initWithJobNo:(NSUInteger)jobNo
                    companyNo:(NSUInteger)companyNo
             postingStartDate:(NSString *)postingStartDate
               postingEndDate:(NSString *)postingEndDate
                     jobTitle:(NSString *)jobTitle
                  jobImageUrl:(NSString *)jobImageUrl
                  jobLocation:(NSString *)jobLocation
         jobInterviewLocation:(NSString *)jobInterviewLocation
                    jobSalary:(NSString *)jobSalary
                jobDetailInfo:(NSString *)jobDetailInfo;

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;
@end

NS_ASSUME_NONNULL_END
