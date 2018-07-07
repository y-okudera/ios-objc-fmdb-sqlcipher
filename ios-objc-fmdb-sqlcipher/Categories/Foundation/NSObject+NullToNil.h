//
//  NSObject+NullToNil.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NullToNil)

- (__kindof NSObject *)nullToNil;
@end

NS_ASSUME_NONNULL_END
