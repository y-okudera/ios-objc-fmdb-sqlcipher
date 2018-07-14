# ios-objc-fmdb-sqlcipher
FMDB/SQLCipherのデモ(Objective-C)


## FMResultSetInitializableプロトコルに準拠したテーブル毎のモデルクラスを定義

FMResultSetInitializableプロトコルに準拠して、以下のプロパティとイニシャライザを必ず定義する。
- `@property (nonatomic) TableModel tableModel;`
- `- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;`

CompanyMaster.h
```objc
#import <Foundation/Foundation.h>
#import "FMResultSetInitializable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 company_masterテーブルのDTO
 */
@interface CompanyMaster : NSObject <FMResultSetInitializable>

@property (nonatomic) TableModel tableModel;
@property (nonatomic) NSUInteger companyNo;
@property (nonatomic) NSString *companyName;
@property (nonatomic) NSUInteger companyEmployeesCount;

- (instancetype)initWithCompanyNo:(NSUInteger)companyNo
                      companyName:(NSString *)companyName
            companyEmployeesCount:(NSUInteger)companyEmployeesCount;

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;
@end

NS_ASSUME_NONNULL_END
```

CompanyMaster.m
```objc
#import "CompanyMaster.h"

@implementation CompanyMaster

- (instancetype)initWithCompanyNo:(NSUInteger)companyNo
                      companyName:(NSString *)companyName
            companyEmployeesCount:(NSUInteger)companyEmployeesCount {

    self = [super init];
    if (self) {
        self.tableModel = TableModelCompanyMaster;
        self.companyNo = companyNo;
        self.companyName = companyName;
        self.companyEmployeesCount = companyEmployeesCount;
    }
    return self;
}

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet {

    NSUInteger const companyNo = [resultSet longForColumn:@"company_no"];
    NSString *const companyName = [[resultSet stringForColumn:@"company_name"] nullToNil];
    NSUInteger const companyEmployeesCount = [resultSet longForColumn:@"company_employees_count"];

    return [self initWithCompanyNo:companyNo companyName:companyName companyEmployeesCount:companyEmployeesCount];
}

@end
```

## DBアクセス時にエラーが発生した場合にハンドリングするためのクラスを実装
sqlite3_errcode, sqlite3_errmsg
およびエラー発生場所が以下の何れかを特定するための情報を格納する。

|エラー発生場所|
|:-----:|
|Open|
|Setkey|
|ExecuteQuery|
|ExecuteUpdate|

DataAccessError.h
```objc
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const dataAccessErrorDomain;

extern NSString *const dataAccessErrorStatementOpen;
extern NSString *const dataAccessErrorStatementSetkey;
extern NSString *const dataAccessErrorStatementExecuteQuery;
extern NSString *const dataAccessErrorStatementExecuteUpdate;

typedef NSString *DataAccessErrorUserInfoKey;
extern DataAccessErrorUserInfoKey const DAEErrorStatementKey;
extern DataAccessErrorUserInfoKey const DAELastErrorCode;
extern DataAccessErrorUserInfoKey const DAELastErrorMessage;

@interface DataAccessError : NSObject

@property (nonatomic) NSError *error;
- (instancetype)initWithLastErrorCode:(int)lastErrorCode
                     lastErrorMessage:(NSString *)lastErrorMessage
                       errorStatement:(NSString *)errorStatement;
NS_ASSUME_NONNULL_END
- (nonnull UIAlertController *)showAlertWithHandler:(nullable void (^)(void))handler;
@end
```

DataAccessError.m
```objc
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
```

## DBアクセスする共通処理をコールするクラスを実装
DBアクセスは直接実装せず、必ずEncryptedDAOのシングルトンインスタンスからメソッドをコールする。

CompanyMasterRepository.h
```objc
#import <Foundation/Foundation.h>
#import "CompanyMaster.h"
#import "DataAccessError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CompanyMasterRepository <NSObject>

#pragma mark - INSERT

/**
 複数件INSERT

 @param newDataArray (NSArray <CompanyMaster *> *) INSERTする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray error:(DataAccessError **)error;

#pragma mark - UPDATE

/**
 複数件UPDATE

 @param updateDataArray (NSArray <CompanyMaster *> *) UPDATEする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray error:(DataAccessError **)error;

/**
 1件UPDATE

 @param companyNo (NSUInteger) 会社No
 @param companyName (NSString *) 会社名
 @param companyEmployeesCount (NSUInteger) 従業員数
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount
                      error:(DataAccessError **)error;

#pragma mark - DELETE

/**
 1件削除

 @param companyNo (NSUInteger) 削除する会社の会社No
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 全データ削除

 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithError:(DataAccessError **)error;

#pragma mark - SELECT

/**
 全件取得する

 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectAllWithError:(DataAccessError **)error;

/**
 company_noを指定してレコードを1件取得する

 @param companyNo (NSUInteger) 取得するレコードのcompany_no
 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 従業員数がxx以上のレコードを取得する

 @param threshold 閾値
 @param error エラーオブジェクト
 @return 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold error:(DataAccessError **)error;

@end

@interface CompanyMasterRepositoryImpl : NSObject <CompanyMasterRepository>

#pragma mark - INSERT

/**
 複数件INSERT

 @param newDataArray (NSArray <CompanyMaster *> *) INSERTする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray error:(DataAccessError **)error;

#pragma mark - UPDATE

/**
 複数件UPDATE

 @param updateDataArray (NSArray <CompanyMaster *> *) UPDATEする情報の配列
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray error:(DataAccessError **)error;

/**
 1件UPDATE

 @param companyNo (NSUInteger) 会社No
 @param companyName (NSString *) 会社名
 @param companyEmployeesCount (NSUInteger) 従業員数
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount
                      error:(DataAccessError **)error;

#pragma mark - DELETE

/**
 1件削除

 @param companyNo (NSUInteger) 削除する会社の会社No
 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 全データ削除

 @param error エラーオブジェクト
 @return YES: 成功, NO: 失敗
 */
- (BOOL)truncateWithError:(DataAccessError **)error;

#pragma mark - SELECT

/**
 全件取得する

 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectAllWithError:(DataAccessError **)error;

/**
 company_noを指定してレコードを1件取得する

 @param companyNo (NSUInteger) 取得するレコードのcompany_no
 @param error エラーオブジェクト
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error;

/**
 従業員数がxx以上のレコードを取得する

 @param threshold 閾値
 @param error エラーオブジェクト
 @return 取得結果
 */
- (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold error:(DataAccessError **)error;
@end

NS_ASSUME_NONNULL_END
```

CompanyMasterRepository.m
```objc
#import "CompanyMasterRepository.h"
#import "EncryptedDAO.h"
#import "SelectResult.h"
#import "SQLiteRequest.h"

@implementation CompanyMasterRepositoryImpl

#pragma mark - INSERT

- (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray error:(DataAccessError **)error {

    NSMutableArray <SQLiteRequest *> *insertRequests = [@[] mutableCopy];
    NSString *const sql = @"INSERT INTO company_master(company_name, company_employees_count) VALUES(?, ?);";

    for (CompanyMaster *companyMaster in newDataArray) {

        NSArray *parameters = @[companyMaster.companyName, @(companyMaster.companyEmployeesCount)];
        SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];
        [insertRequests addObject:request];
    }

    return [[EncryptedDAO shared] inTransaction:insertRequests.copy error:error];
}

#pragma mark - UPDATE

- (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray error:(DataAccessError **)error {

    NSMutableArray <SQLiteRequest *> *updateRequests = [@[] mutableCopy];
    NSString *const sql = @"UPDATE company_master SET company_name = ?, company_employees_count = ? WHERE company_no = ?;";

    for (CompanyMaster *companyMaster in updateDataArray) {

        NSArray *parameters = @[companyMaster.companyName, @(companyMaster.companyEmployeesCount), @(companyMaster.companyNo)];
        SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];
        [updateRequests addObject:request];
    }

    return [[EncryptedDAO shared] inTransaction:updateRequests error:error];
}

- (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount
                      error:(DataAccessError **)error {

    NSString *const sql = @"UPDATE company_master SET company_name = ?, company_employees_count = ? WHERE company_no = ?;";
    NSArray *const parameters = @[companyName, @(companyEmployeesCount), @(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];

    return [[EncryptedDAO shared] inTransaction:@[request] error:error];
}

#pragma mark - DELETE

- (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error {

    NSString *const sql = @"DELETE FROM company_master WHERE company_no = ?;";
    NSArray *const parameter = @[@(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameter];

    return [[EncryptedDAO shared] inTransaction:@[request] error:error];
}

- (BOOL)truncateWithError:(DataAccessError **)error {
    return [[EncryptedDAO shared] truncateWithTableName:@"company_master" error:error];
}

#pragma mark - SELECT

- (NSArray <CompanyMaster *> *)selectAllWithError:(DataAccessError **)error {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master;";
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql
                                                       parameters:nil
                                                       tableModel:TableModelCompanyMaster];
    SelectResult <CompanyMaster *>*result = [[SelectResult alloc] initWithTableModel:TableModelCompanyMaster resultType:CompanyMaster.new];

    [[EncryptedDAO shared] executeQuery:request result:result error:error];

    return result.resultArray.copy;
}

- (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo error:(DataAccessError **)error {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master WHERE company_no = ?;";
    NSArray *const parameter = @[@(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql
                                                       parameters:parameter
                                                       tableModel:TableModelCompanyMaster];
    SelectResult <CompanyMaster *>*result = [[SelectResult alloc] initWithTableModel:TableModelCompanyMaster resultType:CompanyMaster.new];

    [[EncryptedDAO shared] executeQuery:request result:result error:error];

    return result.resultArray.copy;
}

- (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold error:(DataAccessError **)error {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master WHERE company_employees_count >= ?;";
    NSArray *const parameter = @[@(threshold)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql
                                                       parameters:parameter
                                                       tableModel:TableModelCompanyMaster];
    SelectResult <CompanyMaster *>*result = [[SelectResult alloc] initWithTableModel:TableModelCompanyMaster resultType:CompanyMaster.new];

    [[EncryptedDAO shared] executeQuery:request result:result error:error];

    return result.resultArray.copy;
}
@end
```
