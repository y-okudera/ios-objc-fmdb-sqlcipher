//
//  CompanyMasterTableCache.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/22.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyMaster.h"

NS_ASSUME_NONNULL_BEGIN

@interface CompanyMasterTableCache : NSObject

+ (CompanyMasterTableCache *)shared;

/**
 キャッシュをクリアする
 */
- (void)clearCache;

/**
 キャッシュを保存する

 @param results (NSArray <CompanyMaster *> *) キャッシュするデータの配列
 */
- (void)saveCachesWithSelectResults:(NSArray <CompanyMaster *> *)results;

/**
 キャッシュが存在するかどうか

 @return (BOOL) YES: 存在する, NO: 存在しない
 */
- (BOOL)existCaches;

NS_ASSUME_NONNULL_END

/**
 指定条件を満たすデータをキャッシュから取得する

 predicateがnilの場合は、キャッシュデータを全件返す

 @param predicate 条件
 @return 指定条件を満たしたデータの配列
 */
- (nonnull NSArray <CompanyMaster *> *)readCachesWithPredicate:(nullable NSPredicate *)predicate;
@end
