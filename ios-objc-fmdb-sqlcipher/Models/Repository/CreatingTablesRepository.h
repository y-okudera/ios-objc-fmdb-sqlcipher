//
//  CreatingTablesRepository.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CreatingTablesRepository <NSObject>

- (BOOL)createAllTablesWithError:(DataAccessError **)error;

@end

@interface CreatingTablesRepositoryImpl : NSObject <CreatingTablesRepository>

- (BOOL)createAllTablesWithError:(DataAccessError **)error;
@end

NS_ASSUME_NONNULL_END
