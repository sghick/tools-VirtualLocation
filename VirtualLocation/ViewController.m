//
//  ViewController.m
//  VirtualLocation
//
//  Created by 丁治文 on 2019/5/8.
//  Copyright © 2019 sumrise. All rights reserved.
//

#import "ViewController.h"

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
    self.navigationView.title = @"虚拟定位";
    
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
    NSArray<NSString *> *gdstrs = @[@"39.8338830351,116.2907552719",
                                    @"39.8342784928,116.2896233797",
                                    @"39.8345874425,116.2900042534",
                                    @"39.8338912738,116.2919837236",
                                    @"39.8345668459,116.2927347422",
                                    @"39.8361651241,116.2947678566",
                                    @"39.8370054410,116.2961143255",
                                    @"39.8362516278,116.2963718176",
                                    @"39.8387066393,116.2963610888",
                                    @"39.8410215195,116.2947732210",
                                    @"39.8419523924,116.2934106588",
                                    @"39.8434804793,116.2936413288",
                                    @"39.8453545018,116.2938344479",
                                    @"39.8474055711,116.2927132845",
                                    @"39.8477515286,116.2936145067",
                                    @"39.8481016028,116.2944567204",
                                    @"39.8470019519,116.2957173586",
                                    @"39.8459228766,116.2953901291",
                                    @"39.8456304525,116.2965005636",
                                    @"39.8535831204,116.2961786985",
                                    @"39.8537807928,116.2972140312",
                                    @"39.8545055867,116.2984049320",
                                    @"39.8543326252,116.2992149591",
                                    @"39.8552550815,116.2997353077",
                                    @"39.8559510336,116.3021117449",
                                    @"39.8570423052,116.3007920980",
                                    @"39.8574623372,116.3033777475",
                                    @"39.8584753449,116.3034850359",
                                    @"39.8635031012,116.3040107489",
                                    @"39.8646436629,116.3056683540",
                                    @"39.8655206884,116.3046276569",
                                    @"39.8663812331,116.3065588474",
                                    @"39.8665994557,116.3075512648",
                                    @"39.8653642246,116.3090264797",
                                    @"39.8645860176,116.3082271814",
                                    @"39.8638036842,116.3094878197",
                                    @"39.8624160499,116.3092678785",
                                    @"39.8604848445,116.3082593679",
                                    @"39.8592536212,116.3072508574",
                                    @"39.8583106292,116.3075083494",
                                    @"39.8580512012,116.3058561087"];
    
    for (NSString *txt in gdstrs) {
        NSArray<NSString *> *ls = [txt componentsSeparatedByString:@","];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(ls.firstObject.doubleValue, ls.lastObject.doubleValue);
        CLLocationCoordinate2D scoor = [SMRUtils transformFromBDToGPSWithCoordinate:coor];
        NSString *result = [NSString stringWithFormat:@"<wpt lat='%@' lon='%@'>", @(scoor.latitude), @(scoor.longitude)];
        NSLog(@"%@", result);
    }
    
    
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
