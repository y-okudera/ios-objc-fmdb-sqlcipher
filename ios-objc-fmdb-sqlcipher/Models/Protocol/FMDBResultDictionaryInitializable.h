//
//  FMDBResultDictionaryInitializable.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NullToNil.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FMDBResultDictionaryInitializable <NSObject>
- (instancetype)initWithResultDictionary:(NSDictionary *)resultDictionary;

@end

NS_ASSUME_NONNULL_END
