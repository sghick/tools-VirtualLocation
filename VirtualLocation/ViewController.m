//
//  ViewController.m
//  VirtualLocation
//
//  Created by 丁治文 on 2019/5/8.
//  Copyright © 2019 sumrise. All rights reserved.
//

#import "ViewController.h"
#import <SafariServices/SafariServices.h>

@interface ViewController ()<
UITextFieldDelegate>

@property (strong, nonatomic) UITextView *statusLabel;
@property (strong, nonatomic) UITextField *typeField;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITextField *valueTextField;

@property (assign, nonatomic) NSInteger hisIndexForScheme;
@property (assign, nonatomic) NSInteger hisIndexForIndentifier;
@property (assign, nonatomic) NSInteger hisIndexForWebURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationView.backBtnHidden = YES;
    self.navigationView.rightView = [self buttonWithTitle:@"坐标" action:@selector(findBtnClick)];
    
    self.title = @"虚拟定位";
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.typeField];
    [self.view addSubview:self.timeLabel];
    [self.view addSubview:self.valueTextField];
    
    NSArray<UIButton *> *array = @[[self buttonWithTitle:@"高德" action:@selector(GD2GPSBtnClick)],
                                   [self buttonWithTitle:@"百度" action:@selector(BD2GPSBtnClick)],
                                   [self buttonWithTitle:@"    " action:@selector(location1Click)],
                                   [self buttonWithTitle:@"    " action:@selector(location1Click)],
                                   [self buttonWithTitle:@"位置1" action:@selector(location1Click)],
                                   [self buttonWithTitle:@"位置2" action:@selector(location2Click)],
                                   [self buttonWithTitle:@"位置3" action:@selector(location3Click)],
                                   [self buttonWithTitle:@"位置4" action:@selector(location4Click)]];
    
    self.statusLabel.frame = CGRectMake(20, self.navigationView.bottom + 10, SCREEN_WIDTH - 2*20, 80);
    self.typeField.frame = CGRectMake(20, self.statusLabel.bottom + 10, SCREEN_WIDTH - 3*20 - 150, 40);
    self.timeLabel.frame = CGRectMake(self.typeField.right + 10, self.statusLabel.bottom + 10, 150, 40);
    self.valueTextField.frame = CGRectMake(20, self.typeField.bottom + 10, SCREEN_WIDTH - 2*20, 40);
    
    CGRect showBounds = CGRectMake(20, self.valueTextField.bottom + 10, SCREEN_WIDTH - 2*20, SCREEN_HEIGHT - (self.valueTextField.bottom + 10));
    CGSize cellSize = CGSizeMake(80, 80);
    SMRMatrixCalculator *calculator = [SMRMatrixCalculator calculatorForVerticalWithBounds:showBounds
                                                                              columnsCount:4
                                                                                spaceOfRow:10
                                                                                  cellSize:cellSize];
    
    for (int i = 0; i < array.count; i++) {
        UIButton *view = array[i];
        view.frame = [calculator cellFrameWithIndex:i];
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        view.backgroundColor = [UIColor smr_colorWithHexRGB:@"#BBBBBB"];
        view.layer.cornerRadius = 3;
        view.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        view.layer.borderWidth = 1;
        
        [self.view addSubview:view];
    }
    
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf updateTimer];
        }];
    } else {
        // Fallback on earlier versions
        [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(updateTimer) userInfo:nil repeats:YES];
    }
}

#pragma mark - Utils

- (void)updateTimer {
    self.timeLabel.text = [SMRUtils convertToStringFromDate:[NSDate date] format:@"yyyy年MM月dd日\nHH:mm:ss"];
}

- (NSArray<NSError *> *)validateEmptyWithTextFields:(NSArray<UITextField *> *)textFields {
    NSMutableArray *arr = [NSMutableArray array];
    for (UITextField *txt in textFields) {
        if (!txt.text.length) {
            NSError *error = [NSError smr_errorWithDomain:@"com.SMR.debug.validate.error.domain"
                                                     code:100
                                                   detail:txt.placeholder
                                                  message:nil
                                                 userInfo:@{@"object":txt}];
            [arr addObject:error];
            break;
        }
    }
    return [arr copy];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.numberOfLines = 0;
    return btn;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Actions

- (void)findBtnClick {
    SFSafariViewController *web = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.gpsspg.com/maps.htm"]];
    [SMRNavigator pushOrPresentToViewController:web animated:YES];
}

- (void)GD2GPSBtnClick {
    NSString *txt = self.valueTextField.text;
    NSArray<NSString *> *ls = [txt componentsSeparatedByString:@","];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(ls.firstObject.doubleValue, ls.lastObject.doubleValue);
    CLLocationCoordinate2D scoor = [SMRUtils transformFromGDToGPSWithCoordinate:coor];
    NSString *result = [NSString stringWithFormat:@"高德:%@\n<wpt lat='%@' lon='%@'>", txt, @(scoor.latitude), @(scoor.longitude)];
    self.statusLabel.text = result;
}

- (void)BD2GPSBtnClick {
    NSString *txt = self.valueTextField.text;
    NSArray<NSString *> *ls = [txt componentsSeparatedByString:@","];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(ls.firstObject.doubleValue, ls.lastObject.doubleValue);
    CLLocationCoordinate2D scoor = [SMRUtils transformFromBDToGPSWithCoordinate:coor];
    NSString *result = [NSString stringWithFormat:@"百度:\n<wpt lat='%@' lon='%@'>", @(scoor.latitude), @(scoor.longitude)];
    self.statusLabel.text = result;
}

- (void)location1Click {
    NSString *coorstr = [NSString stringWithFormat:@"39.8966334273,116.4636182785"];
    self.valueTextField.text = coorstr;
    [self GD2GPSBtnClick];
}

- (void)location2Click {
    
}

- (void)location3Click {
    
}

- (void)location4Click {
    
}

#pragma mark - Getters

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
        _typeField.placeholder = @"GD";
        _typeField.textColor = [UIColor grayColor];
        _typeField.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _typeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _typeField.leftViewMode = UITextFieldViewModeAlways;
        _typeField.clearButtonMode = UITextFieldViewModeAlways;
        _typeField.delegate = self;
    }
    return _typeField;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = [UIColor redColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.numberOfLines = 2;
    }
    return _timeLabel;
}

- (UITextField *)valueTextField {
    if (!_valueTextField) {
        _valueTextField = [[UITextField alloc] init];
        _valueTextField.font = [UIFont systemFontOfSize:15];
        _valueTextField.placeholder = @"请输入火星坐标,如:39.01234,116.01234";
        _valueTextField.textColor = [UIColor grayColor];
        _valueTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _valueTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _valueTextField.leftViewMode = UITextFieldViewModeAlways;
        _valueTextField.clearButtonMode = UITextFieldViewModeAlways;
        _valueTextField.delegate = self;
    }
    return _valueTextField;
}

@end
