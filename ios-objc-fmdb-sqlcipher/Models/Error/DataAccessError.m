//
//  DataAccessError.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/14.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "DataAccessError.h"

/// domain
NSString *const dataAccessErrorDomain = @"jp.yuoku.ios-objc-fmdb-sqlcipher.dataAccess";

// dataAccessErrorStatement
NSString *const dataAccessErrorStatementOpen = @"Open failed.";
NSString *const dataAccessErrorStatementSetkey = @"Setkey failed.";
NSString *const dataAccessErrorStatementExecuteQuery = @"Query execution failed.";
NSString *const dataAccessErrorStatementExecuteUpdate = @"Update execution failed.";

/// userInfoKey
DataAccessErrorUserInfoKey const DAEErrorStatementKey = @"errorStatement";
DataAccessErrorUserInfoKey const DAELastErrorCode = @"lastErrorCode";
DataAccessErrorUserInfoKey const DAELastErrorMessage = @"lastErrorMessage";

@implementation DataAccessError

- (instancetype)initWithLastErrorCode:(int)lastErrorCode
                     lastErrorMessage:(NSString *)lastErrorMessage
                       errorStatement:(NSString *)errorStatement {

    self = [super init];
    if (self) {

        NSDictionary *userInfo = @{
                                   DAELastErrorCode: @(lastErrorCode),
                                   DAELastErrorMessage: lastErrorMessage,
                                   DAEErrorStatementKey: errorStatement
                                   };


        self.error = [NSError errorWithDomain:dataAccessErrorDomain
                                         code:lastErrorCode
                                     userInfo:userInfo];
    }
    return self;
}

- (UIAlertController *)showAlertWithHandler:(void (^)(void))handler {

    NSString *title = [NSString stringWithFormat:@"データアクセスエラー: %@", self.error.userInfo[DAELastErrorCode]];
    NSString *message = self.error.userInfo[DAELastErrorMessage];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         if (handler) {
                                                             handler();
                                                         }
                                                     }];
    [alertController addAction:okAction];

    return alertController;
}
@end
