//
//  ViewController.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/07.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "ViewController.h"

#import "CompanyMasterRepository.h"
#import "CreatingTablesRepository.h"
#import "EncryptedDAO.h"
#import "SQLCipherMigrator.h"

@interface ViewController ()
@property (nonatomic) CompanyMasterRepositoryImpl *companyMasterRepository;
@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.companyMasterRepository = [[CompanyMasterRepositoryImpl alloc] init];
    
    // Main bundleのplain.sqlite3(非暗号DB)をコピー
    BOOL resultOfCopyDB = [self copyPlainSQLite3];
    if (resultOfCopyDB) {
        NSLog(@"コピー作成成功");
    } else {
        NSLog(@"コピー作成失敗");
    }
    
    // 移行処理を実行
    BOOL resultOfMigration = [[SQLCipherMigrator shared] migrateToEncryptedDB];
    if (resultOfMigration) {
        NSLog(@"SQLCipherへの移行成功");
    } else {
        NSLog(@"SQLCipherへの移行失敗");
    }
    
    NSArray <NSString *> *tableNames = [[EncryptedDAO shared] selectTableNames];
    if (tableNames.count == 0) {
        NSLog(@"TABLE 無し");
    } else {
        NSLog(@"%@", tableNames);
    }
    
    // company_masterテーブルを初期化
    BOOL truncateResult = [self.companyMasterRepository truncate];
    if (truncateResult) {
        NSLog(@"company_masterテーブルTRUNCATE成功");
    } else {
        NSLog(@"company_masterテーブルTRUNCATE失敗");
    }
    
    // 暗号化DBを操作
    [self accessEncryptedDB];
}

#pragma mark - Copy plain.sqlite3 from the main bundle

/**
 Main bundleからDocumentsディレクトリにplain.sqlite3をコピーする

 @return YES: 成功, NO: 失敗
 */
- (BOOL)copyPlainSQLite3 {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *copyError = nil;

    BOOL resultOfCopy = [fileManager copyItemAtPath:[self resourcePath]
                                             toPath:[self saveDBPath]
                                              error:&copyError];
    if (!resultOfCopy) {
        NSLog(@"copyError code: %ld, description: %@", copyError.code, copyError.description);
        return NO;
    }
    return YES;
}

#pragma mark - Path

- (NSString *)resourcePath {
    return [NSBundle.mainBundle pathForResource:@"plain" ofType:@"sqlite3"];
}

- (NSString *)saveDBPath {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES).firstObject;
    return [documentsDirectory stringByAppendingPathComponent:sqlitePlainDBName];
}

#pragma mark - Access encrypted database

/**
 暗号化DBを操作する
 */
- (void)accessEncryptedDB {
    const int numberOfTrials = 10;
    const int operationsPerTransaction = 10;

    // INSERT -> UPDATE
    for (int i = 0; i < numberOfTrials; i++) {

        NSMutableArray <CompanyMaster *> *models = [@[] mutableCopy];
        @autoreleasepool {
            for (int j = 0; j < operationsPerTransaction; j++) {

                @autoreleasepool {
                    CompanyMaster *model = [[CompanyMaster alloc] initWithCompanyNo:i+j
                                                                        companyName:[NSString stringWithFormat:@"株式会社%d-%d", i, j]
                                                              companyEmployeesCount:300];
                    [models addObject:model];
                }
            }

            BOOL insertResult = [self.companyMasterRepository insertWithCompanyMasterArray:models];
            if (insertResult) {
                NSLog(@"i = %d INSERT成功", i);
            } else {
                NSLog(@"i = %d INSERT失敗", i);
            }
        }

        NSMutableArray <CompanyMaster *> *updateModels = [@[] mutableCopy];
        @autoreleasepool {
            for (int k = 0; k < operationsPerTransaction; k++) {

                @autoreleasepool {
                    CompanyMaster *updateModel = [[CompanyMaster alloc] initWithCompanyNo:i+k
                                                                              companyName:[NSString stringWithFormat:@"<UPDATE>株式会社%d-%d", i, k]
                                                                    companyEmployeesCount:1000];
                    [updateModels addObject:updateModel];
                }
            }

            BOOL resultOfUpdate = [self.companyMasterRepository updateWithCompanyMasterArray:updateModels];
            if (resultOfUpdate) {
                NSLog(@"i = %d UPDATE成功", i);
            } else {
                NSLog(@"i = %d UPDATE失敗", i);
            }
        }
    }

    // SELECT
    NSArray <CompanyMaster *> *selectedData = [self.companyMasterRepository selectAll];
    NSLog(@"%ld", selectedData.count);
    NSLog(@"%@", selectedData.firstObject.companyName);
    NSLog(@"%ld", selectedData.firstObject.companyEmployeesCount);
}

@end
