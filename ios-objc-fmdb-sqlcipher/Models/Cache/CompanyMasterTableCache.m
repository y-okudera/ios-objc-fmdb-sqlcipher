//
//  CompanyMasterTableCache.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/22.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "CompanyMasterTableCache.h"

@interface CompanyMasterTableCache ()

/// SELECT時に参照するキャッシュ配列のインスタンス
@property (nonatomic) NSArray <CompanyMaster *> *cachedRecords;

/// INSERT, UPDATE, DELETE時に最新レコードをキャッシュするためのインスタンス
@property (nonatomic) NSMutableArray <CompanyMaster *> *mutableCachedRecords;
@end

@implementation CompanyMasterTableCache

# pragma mark - Singleton

static CompanyMasterTableCache *sharedInstance = nil;

+ (CompanyMasterTableCache *)shared {

    // dispatch_once_t を利用することでインスタンス生成を1度に制限する
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[CompanyMasterTableCache alloc] init];
    });
    return sharedInstance;
}

/**
 外部からallocされた時のためにallocWithZoneをオーバーライドして、
 一度しかインスタンスを返さないようにする
 */
+ (id)allocWithZone:(NSZone *)zone {

    __block id ret = nil;

    static dispatch_once_t oncePredicate;
    dispatch_once( &oncePredicate, ^{
        sharedInstance = [super allocWithZone:zone];
        ret = sharedInstance;
    });

    return  ret;
}

/**
 copyで別インスタンスが返されないようにするため
 copyWithZoneをオーバーライドして、自身のインスタンスを返すようにする。
 */
- (id)copyWithZone:(NSZone *)zone{

    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableCachedRecords = [@[] mutableCopy];
        self.cachedRecords = self.mutableCachedRecords.copy;
    }
    return self;
}

- (void)clearCache {
    self.mutableCachedRecords = [@[] mutableCopy];
    self.cachedRecords = self.mutableCachedRecords.copy;
}

- (void)saveCachesWithSelectResults:(NSArray <CompanyMaster *> *)results {
    self.mutableCachedRecords = [results mutableCopy];
    self.cachedRecords = self.mutableCachedRecords.copy;
}

- (BOOL)existCaches {
    if (!self.cachedRecords) {
        return NO;
    }
    if (self.cachedRecords.count == 0) {
        return NO;
    }
    return YES;
}

- (NSArray <CompanyMaster *> *)readCachesWithPredicate:(NSPredicate *)predicate {

    if (!predicate) {
        return self.cachedRecords;
    }
    NSArray <CompanyMaster *> *readData = [self.cachedRecords filteredArrayUsingPredicate:predicate];
    return readData;
}
@end
