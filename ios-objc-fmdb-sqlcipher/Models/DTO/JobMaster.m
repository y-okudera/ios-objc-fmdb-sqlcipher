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
                jobDetailInfo:(NSString *)jobDetailInfo
                  companyName:(NSString *)companyName {

    self = [super init];
    if (self) {
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
        self.companyName = companyName;
    }
    return self;
}

- (instancetype)initWithResultDictionary:(NSDictionary *)resultDictionary {

    NSUInteger const jobNo = [resultDictionary[@"job_no"] unsignedIntegerValue];
    NSUInteger const companyNo = [resultDictionary[@"company_no"] unsignedIntegerValue];
    NSString *const postingStartDate = [resultDictionary[@"posting_start_date"] nullToNil];
    NSString *const postingEndDate = [resultDictionary[@"posting_end_date"] nullToNil];
    NSString *const jobTitle = [resultDictionary[@"job_title"] nullToNil];
    NSString *const jobImageUrl = [resultDictionary[@"job_image_url"] nullToNil];
    NSString *const jobLocation = [resultDictionary[@"job_location"] nullToNil];
    NSString *const jobInterviewLocation = [resultDictionary[@"job_interview_location"] nullToNil];
    NSString *const jobSalary = [resultDictionary[@"job_salary"] nullToNil];
    NSString *const jobDetailInfo = [resultDictionary[@"job_detail_info"] nullToNil];
    NSString *const companyName = [resultDictionary[@"company_name"] nullToNil];

    return [self initWithJobNo:jobNo
                     companyNo:companyNo
              postingStartDate:postingStartDate
                postingEndDate:postingEndDate
                      jobTitle:jobTitle
                   jobImageUrl:jobImageUrl
                   jobLocation:jobLocation
          jobInterviewLocation:jobInterviewLocation
                     jobSalary:jobSalary
                 jobDetailInfo:jobDetailInfo
                   companyName:companyName];
}
@end
