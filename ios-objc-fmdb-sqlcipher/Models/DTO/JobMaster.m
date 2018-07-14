//
//  JobMaster.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "JobMaster.h"

@implementation JobMaster

- (instancetype)initWithJobNo:(NSUInteger)jobNo
                    companyNo:(NSUInteger)companyNo
             postingStartDate:(NSString *)postingStartDate
               postingEndDate:(NSString *)postingEndDate
                     jobTitle:(NSString *)jobTitle
                  jobImageUrl:(NSString *)jobImageUrl
                  jobLocation:(NSString *)jobLocation
         jobInterviewLocation:(NSString *)jobInterviewLocation
                    jobSalary:(NSString *)jobSalary
                jobDetailInfo:(NSString *)jobDetailInfo {

    self = [super init];
    if (self) {
        self.tableModel = TableModelJobMaster;
        self.jobNo = jobNo;
        self.companyNo = companyNo;
        self.postingStartDate = postingStartDate;
        self.postingEndDate = postingEndDate;
        self.jobTitle = jobTitle;
        self.jobImageUrl = jobImageUrl;
        self.jobLocation = jobLocation;
        self.jobInterviewLocation = jobInterviewLocation;
        self.jobSalary = jobSalary;
        self.jobDetailInfo = jobDetailInfo;
    }
    return self;
}

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet {

    NSUInteger const jobNo = [resultSet longForColumn:@"job_no"];
    NSUInteger const companyNo = [resultSet longForColumn:@"company_no"];
    NSString *const postingStartDate = [[resultSet stringForColumn:@"posting_start_date"] nullToNil];
    NSString *const postingEndDate = [[resultSet stringForColumn:@"posting_end_date"] nullToNil];
    NSString *const jobTitle = [[resultSet stringForColumn:@"job_title"] nullToNil];
    NSString *const jobImageUrl = [[resultSet stringForColumn:@"job_image_url"] nullToNil];
    NSString *const jobLocation = [[resultSet stringForColumn:@"job_location"] nullToNil];
    NSString *const jobInterviewLocation = [[resultSet stringForColumn:@"job_interview_location"] nullToNil];
    NSString *const jobSalary = [[resultSet stringForColumn:@"job_salary"] nullToNil];
    NSString *const jobDetailInfo = [[resultSet stringForColumn:@"job_detail_info"] nullToNil];

    return [self initWithJobNo:jobNo
                     companyNo:companyNo
              postingStartDate:postingStartDate
                postingEndDate:postingEndDate
                      jobTitle:jobTitle
                   jobImageUrl:jobImageUrl
                   jobLocation:jobLocation
          jobInterviewLocation:jobInterviewLocation
                     jobSalary:jobSalary
                 jobDetailInfo:jobDetailInfo];
}
@end
