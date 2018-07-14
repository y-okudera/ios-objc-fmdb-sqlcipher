//
//  SQLCipherMigrator.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const sqlitePlainDBName;

@interface SQLCipherMigrator : NSObject

+ (instancetype)shared;

#pragma mark - Encrypt a plain text database

/**
 非暗号化DBをコピーして暗号化DBを生成する

 @return YES: 暗号化成功、非暗号化DB削除成功, NO: 失敗
 */
- (BOOL)migrateToEncryptedDB;
@end

NS_ASSUME_NONNULL_END
