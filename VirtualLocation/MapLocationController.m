//
//  MapLocationController.m
//  VirtualLocation
//
//  Created by 丁治文 on 2019/5/31.
//  Copyright © 2019 sumrise. All rights reserved.
//

#import "MapLocationController.h"

@interface MapLocationController ()

@property (strong, nonatomic) UITextView *statusLabel;
@property (strong, nonatomic) UITextField *typeField;

@end

@implementation MapLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationView.backBtnHidden = YES;
    self.navigationView.title = @"地图定位器";
    
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.typeField];
    
    self.statusLabel.frame = CGRectMake(20, self.navigationView.bottom + 10, SCREEN_WIDTH - 2*20, 80);
    self.typeField.frame = CGRectMake(20, self.statusLabel.bottom + 10, SCREEN_WIDTH - 3*20 - 150, 40);
}

- (UITextView *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UITextView alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textColor = [UIColor grayColor];
        _statusLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _statusLabel.editable = NO;
    }
    return _statusLabel;
}

- (UITextField *)typeField {
    if (!_typeField) {
        _typeField = [[UITextField alloc] init];
        _typeField.font = [UIFont systemFontOfSize:15];
        _typeField.placeholder = @"输入起始坐标(高德)";
        _typeField.textColor = [UIColor grayColor];
        _typeField.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _typeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _typeField.leftViewMode = UITextFieldViewModeAlways;
        _typeField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _typeField;
}

@end
