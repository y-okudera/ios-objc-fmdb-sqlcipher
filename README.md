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

## DBアクセスする共通処理をコールするクラスを実装
DBアクセスは直接実装せず、必ずEncryptedDAOのシングルトンインスタンスからメソッドをコールする。

CompanyMasterRepository.h
```objc
#import <Foundation/Foundation.h>
#import "CompanyMaster.h"

NS_ASSUME_NONNULL_BEGIN

@interface CompanyMasterRepository : NSObject

#pragma mark - INSERT

/**
 複数件INSERT

 @param newDataArray (NSArray <CompanyMaster *> *) INSERTする情報の配列
 @return YES: 成功, NO: 失敗
 */
+ (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray;

#pragma mark - UPDATE

/**
 複数件UPDATE

 @param updateDataArray (NSArray <CompanyMaster *> *) UPDATEする情報の配列
 @return YES: 成功, NO: 失敗
 */
+ (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray;

/**
 1件UPDATE

 @param companyNo (NSUInteger) 会社No
 @param companyName (NSString *) 会社名
 @param companyEmployeesCount (NSUInteger) 従業員数
 @return YES: 成功, NO: 失敗
 */
+ (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount;

#pragma mark - DELETE

/**
 1件削除

 @param companyNo (NSUInteger) 削除する会社の会社No
 @return YES: 成功, NO: 失敗
 */
+ (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo;

/**
 全データ削除

 @return YES: 成功, NO: 失敗
 */
+ (BOOL)truncate;

#pragma mark - SELECT

/**
 全件取得する

 @return (NSArray <CompanyMaster *> *) 取得結果
 */
+ (NSArray <CompanyMaster *> *)selectAll;

/**
 company_noを指定してレコードを1件取得する

 @param companyNo (NSUInteger) 取得するレコードのcompany_no
 @return (NSArray <CompanyMaster *> *) 取得結果
 */
+ (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo;

/**
 従業員数がxx以上のレコードを取得する

 @param threshold 閾値
 @return 取得結果
 */
+ (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold;
@end

NS_ASSUME_NONNULL_END
```

CompanyMasterRepository.m
```objc
#import "CompanyMasterRepository.h"
#import "EncryptedDAO.h"
#import "SelectResult.h"
#import "SQLiteRequest.h"

@implementation CompanyMasterRepository

#pragma mark - INSERT

+ (BOOL)insertWithCompanyMasterArray:(NSArray <CompanyMaster *> *)newDataArray {

    NSMutableArray <SQLiteRequest *> *insertRequests = [@[] mutableCopy];
    NSString *const sql = @"INSERT INTO company_master(company_name, company_employees_count) VALUES(?, ?);";

    for (CompanyMaster *companyMaster in newDataArray) {

        NSArray *parameters = @[companyMaster.companyName, @(companyMaster.companyEmployeesCount)];
        SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];
        [insertRequests addObject:request];
    }

    return [[EncryptedDAO shared] inTransaction:insertRequests.copy];
}

#pragma mark - UPDATE

+ (BOOL)updateWithCompanyMasterArray:(NSArray <CompanyMaster *> *)updateDataArray {

    NSMutableArray <SQLiteRequest *> *updateRequests = [@[] mutableCopy];
    NSString *const sql = @"UPDATE company_master SET company_name = ?, company_employees_count = ? WHERE company_no = ?;";

    for (CompanyMaster *companyMaster in updateDataArray) {

        NSArray *parameters = @[companyMaster.companyName, @(companyMaster.companyEmployeesCount), @(companyMaster.companyNo)];
        SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];
        [updateRequests addObject:request];
    }

    return [[EncryptedDAO shared] inTransaction:updateRequests];
}

+ (BOOL)updateWithCompanyNo:(NSUInteger)companyNo
                companyName:(NSString *)companyName
      companyEmployeesCount:(NSUInteger)companyEmployeesCount {

    NSString *const sql = @"UPDATE company_master SET company_name = ?, company_employees_count = ? WHERE company_no = ?;";
    NSArray *const parameters = @[companyName, @(companyEmployeesCount), @(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameters];

    return [[EncryptedDAO shared] inTransaction:@[request]];
}

#pragma mark - DELETE

+ (BOOL)deleteWithCompanyNo:(NSUInteger)companyNo {

    NSString *const sql = @"DELETE FROM company_master WHERE company_no = ?;";
    NSArray *const parameter = @[@(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql parameters:parameter];

    return [[EncryptedDAO shared] inTransaction:@[request]];
}

+ (BOOL)truncate {
    return [[EncryptedDAO shared] truncateWithTableName:@"company_master"];
}

#pragma mark - SELECT

+ (NSArray <CompanyMaster *> *)selectAll {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master;";
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql
                                                       parameters:nil
                                                       tableModel:TableModelCompanyMaster];
    SelectResult <CompanyMaster *>*result = [[SelectResult alloc] initWithTableModel:TableModelCompanyMaster resultType:CompanyMaster.new];

    [[EncryptedDAO shared] executeQuery:request result:result];

    return result.resultArray.copy;
}

+ (NSArray <CompanyMaster *> *)selectByCompanyNo:(NSUInteger)companyNo {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master WHERE company_no = ?;";
    NSArray *const parameter = @[@(companyNo)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql
                                                       parameters:parameter
                                                       tableModel:TableModelCompanyMaster];
    SelectResult <CompanyMaster *>*result = [[SelectResult alloc] initWithTableModel:TableModelCompanyMaster resultType:CompanyMaster.new];

    [[EncryptedDAO shared] executeQuery:request result:result];

    return result.resultArray.copy;
}

+ (NSArray <CompanyMaster *> *)selectByEmployeesCount:(NSInteger)threshold {

    NSString *const sql = @"SELECT company_no, company_name, company_employees_count FROM company_master WHERE company_employees_count >= ?;";
    NSArray *const parameter = @[@(threshold)];
    SQLiteRequest *request = [[SQLiteRequest alloc] initWithQuery:sql
                                                       parameters:parameter
                                                       tableModel:TableModelCompanyMaster];
    SelectResult <CompanyMaster *>*result = [[SelectResult alloc] initWithTableModel:TableModelCompanyMaster resultType:CompanyMaster.new];

    [[EncryptedDAO shared] executeQuery:request result:result];

    return result.resultArray.copy;
}
@end
```
