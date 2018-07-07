//
//  NSObject+NullToNil.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "NSObject+NullToNil.h"

@implementation NSObject (NullToNil)

- (__kindof NSObject *)nullToNil {
    return [self isEqual:[NSNull null]] ? nil : self;
}
@end
