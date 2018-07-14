//
//  DataAccessErrorStatement.h
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/14.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#ifndef DataAccessErrorStatement_h
#define DataAccessErrorStatement_h

typedef NS_ENUM(NSUInteger, DataAccessErrorStatement) {
    DataAccessErrorStatementOpen,
    DataAccessErrorStatementSetkey,
    DataAccessErrorStatementExecuteQuery,
    DataAccessErrorStatementExecuteUpdate,
    DataAccessErrorStatementClose
};

#endif /* DataAccessErrorStatement_h */
