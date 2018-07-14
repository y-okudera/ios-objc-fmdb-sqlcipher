//
//  DataAccessError.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/14.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const dataAccessErrorDomain;

extern NSString *const dataAccessErrorStatementOpen;
extern NSString *const dataAccessErrorStatementSetkey;
extern NSString *const dataAccessErrorStatementExecuteQuery;
extern NSString *const dataAccessErrorStatementExecuteUpdate;

typedef NSString *DataAccessErrorUserInfoKey;
extern DataAccessErrorUserInfoKey const DAEErrorStatementKey;
extern DataAccessErrorUserInfoKey const DAELastErrorCode;
extern DataAccessErrorUserInfoKey const DAELastErrorMessage;

@interface DataAccessError : NSObject

@property (nonatomic) NSError *error;
- (instancetype)initWithLastErrorCode:(int)lastErrorCode
                     lastErrorMessage:(NSString *)lastErrorMessage
                       errorStatement:(NSString *)errorStatement;
NS_ASSUME_NONNULL_END
- (nonnull UIAlertController *)showAlertWithHandler:(nullable void (^)(void))handler;
@end

