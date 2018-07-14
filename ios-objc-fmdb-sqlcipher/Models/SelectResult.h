//
//  SelectResult.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSetInitializable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectResult<T: __kindof NSObject <FMResultSetInitializable> *> : NSObject

@property (nonatomic, readonly) TableModel tableModel;
@property (nonatomic, readonly) T resultType;
@property (nonatomic) NSMutableArray <T> *resultArray;

- (instancetype)initWithTableModel:(TableModel)tableModel resultType:(T)resultType;
@end

NS_ASSUME_NONNULL_END
