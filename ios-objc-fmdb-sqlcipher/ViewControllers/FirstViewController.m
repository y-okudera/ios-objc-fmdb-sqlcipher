//
//  FirstViewController.m
//  ios-objc-fmdb-sqlcipher
//
//  Created by YukiOkudera on 2018/07/21.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

#import "FirstViewController.h"
#import "CompanyMasterRepository.h"
#import "CreatingTablesRepository.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyEmployeesCountTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyNoTextField;
@property (weak, nonatomic) IBOutlet UITextView *selectResultsTextView;

@property (nonatomic) CompanyMasterRepositoryImpl *companyMasterRepositoryImpl;
@property (nonatomic) CreatingTablesRepositoryImpl *creatingTablesRepositoryImpl;
@end

@implementation FirstViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.companyMasterRepositoryImpl = [[CompanyMasterRepositoryImpl alloc] init];
    self.creatingTablesRepositoryImpl = [[CreatingTablesRepositoryImpl alloc] init];

    DataAccessError *dataAccessError = nil;
    BOOL createSuccess = [self.creatingTablesRepositoryImpl createAllTablesWithError:&dataAccessError];
    if (createSuccess) {
        NSLog(@"Table 作成成功");
    }
}

#pragma mark - IBActions

- (IBAction)didTapInsert:(UIButton *)sender {

    CompanyMaster *companyMaster = [[CompanyMaster alloc] initWithCompanyNo:[self inputCompanyNo]
                                                                companyName:[self inputCompanyName]
                                                      companyEmployeesCount:[self inputCompanyEmployeesCount]];
    DataAccessError *dataAccessError = nil;
    BOOL insertResult = [self.companyMasterRepositoryImpl insertWithCompanyMasterArray:@[companyMaster] error:&dataAccessError];

    if (!insertResult) {
        NSLog(@"%ld", dataAccessError.error.code);
        NSLog(@"%@", dataAccessError.error.userInfo);
    }
}

- (IBAction)didTapDelete:(UIButton *)sender {

    DataAccessError *dataAccessError = nil;
    BOOL deleteResult = [self.companyMasterRepositoryImpl deleteWithCompanyNo:[self inputCompanyNo] error:&dataAccessError];

    if (!deleteResult) {
        NSLog(@"%ld", dataAccessError.error.code);
        NSLog(@"%@", dataAccessError.error.userInfo);
    }
}

- (IBAction)didTapSelectAll:(UIButton *)sender {

    DataAccessError *dataAccessError = nil;
    NSArray <CompanyMaster *> *results = [self.companyMasterRepositoryImpl selectAllWithError:&dataAccessError];

    if (results) {
        NSMutableString *resultText = [[NSString stringWithFormat:@"COUNT: %ld\n", results.count] mutableCopy];
        for (CompanyMaster *result in results) {
            [resultText appendString:result.description];
        }
        [self outputResults:resultText.copy];
    }
}

- (IBAction)didTapDeleteAll:(UIButton *)sender {

    DataAccessError *dataAccessError = nil;
    BOOL truncateResult = [self.companyMasterRepositoryImpl truncateWithError:&dataAccessError];
    if (!truncateResult) {
        NSLog(@"%ld", dataAccessError.error.code);
        NSLog(@"%@", dataAccessError.error.userInfo);
    }
}

- (IBAction)didTapBaseView:(UITapGestureRecognizer *)sender {
    if (self.companyNameTextField.canResignFirstResponder) {
        [self.companyNameTextField resignFirstResponder];
    }

    if (self.companyEmployeesCountTextField.canResignFirstResponder) {
        [self.companyEmployeesCountTextField resignFirstResponder];
    }

    if (self.companyNoTextField.canResignFirstResponder) {
        [self.companyNoTextField resignFirstResponder];
    }
}

#pragma mark - Others

- (NSString *)inputCompanyName {
    return self.companyNameTextField.text;
}

- (NSUInteger)inputCompanyEmployeesCount {
    if ([self.companyEmployeesCountTextField.text isEqualToString:@""]) {
        return 0;
    }
    return [self.companyEmployeesCountTextField.text integerValue];
}

- (NSUInteger)inputCompanyNo {
    if ([self.companyNoTextField.text isEqualToString:@""]) {
        return 0;
    }
    return [self.companyNoTextField.text integerValue];
}

- (void)outputResults:(NSString *)text {
    self.selectResultsTextView.text = text;
    [self.selectResultsTextView setContentOffset:CGPointZero animated:YES];
}

@end
