//
//  SwipLocationController.m
//  VirtualLocation
//
//  Created by 丁治文 on 2019/5/31.
//  Copyright © 2019 sumrise. All rights reserved.
//

#import "SwipLocationController.h"

@interface SwipLocationController ()

@property (strong, nonatomic) UITextView *statusLabel;
@property (strong, nonatomic) UITextField *typeField;
@property (strong, nonatomic) UIButton *applyButton;
@property (strong, nonatomic) UIButton *pauseButton;

@property (assign, nonatomic) CLLocationCoordinate2D curlocation;

@property (assign, nonatomic) CGFloat step;

@end

@implementation SwipLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationView.backBtnHidden = YES;
    self.navigationView.title = @"定位移动器";
    
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.typeField];
    [self.view addSubview:self.applyButton];
    [self.view addSubview:self.pauseButton];
    
    self.step = 0.0015;
    
    self.statusLabel.frame = CGRectMake(20, self.navigationView.bottom + 10, SCREEN_WIDTH - 2*20, 80);
    self.typeField.frame = CGRectMake(20, self.statusLabel.bottom + 10, SCREEN_WIDTH - 2*20, 40);
    self.applyButton.frame = CGRectMake(20, self.typeField.bottom + 10, 200, 40);
    self.pauseButton.frame = CGRectMake(self.applyButton.right + 20, self.typeField.bottom + 10, SCREEN_WIDTH - self.applyButton.right - 2*20, 40);
    
    NSArray<UIButton *> *array = @[[self buttonWithTitle:@"↖️" action:@selector(button7Action:)],
                                   [self buttonWithTitle:@"⬆️" action:@selector(button8Action:)],
                                   [self buttonWithTitle:@"↗️" action:@selector(button9Action:)],
                                   [self buttonWithTitle:@"⬅️" action:@selector(button4Action:)],
                                   [self buttonWithTitle:@"🔄" action:@selector(button5Action:)],
                                   [self buttonWithTitle:@"➡️" action:@selector(button6Action:)],
                                   [self buttonWithTitle:@"↙️" action:@selector(button1Action:)],
                                   [self buttonWithTitle:@"⬇️" action:@selector(button2Action:)],
                                   [self buttonWithTitle:@"↘️" action:@selector(button3Action:)]];
    CGRect showBounds = CGRectMake(75, self.applyButton.bottom + 40, SCREEN_WIDTH - 2*75, SCREEN_HEIGHT);
    CGSize cellSize = CGSizeMake(80, 80);
    SMRMatrixCalculator *calculator = [SMRMatrixCalculator calculatorForVerticalWithBounds:showBounds
                                                                              columnsCount:3
                                                                                spaceOfRow:10
                                                                                  cellSize:cellSize];
    
    for (int i = 0; i < array.count; i++) {
        UIButton *view = array[i];
        view.frame = [calculator cellFrameWithIndex:i];
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        view.backgroundColor = [UIColor smr_colorWithHexRGB:@"#BBBBBB"];
        view.layer.cornerRadius = 10;
        view.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        view.layer.borderWidth = 1;
        
        [self.view addSubview:view];
    }
}

#pragma mark - Utils

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.numberOfLines = 0;
    return btn;
}

- (CLLocationCoordinate2D)coordinate2DWithText:(NSString *)text {
    NSArray<NSString *> *ls = [text componentsSeparatedByString:@","];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(ls.firstObject.doubleValue, ls.lastObject.doubleValue);
    return coor;
}

- (NSString *)textWithCoordinate2D:(CLLocationCoordinate2D)coor {
    NSString *result = [NSString stringWithFormat:@"%@,%@", @(coor.latitude), @(coor.longitude)];
    return result;
}

- (NSString *)textOfGPXWithCoordinate2D:(CLLocationCoordinate2D)coor {
    NSString *result = [NSString stringWithFormat:@"<wpt lat='%@' lon='%@'></wpt>", @(coor.latitude), @(coor.longitude)];
//    printf("%s\n", [result cStringUsingEncoding:NSUTF8StringEncoding]);
    printf("<!-- %s -->\n", [result cStringUsingEncoding:NSUTF8StringEncoding]);
    return result;
}

- (CLLocationCoordinate2D)transformFromToGPSWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [SMRUtils transformFromGDToGPSWithCoordinate:coordinate];
}

#pragma mark - Private

- (void)o:(NSInteger)number {
    [self p_newCoordinate2DWithNumber:number];
}

- (void)p_newCoordinate2DWithNumber:(NSInteger)number {
    [self p_newCoordinate2DWithBlock:^CLLocationCoordinate2D(CLLocationCoordinate2D coor) {
        switch (number) {
            case 7: return CLLocationCoordinate2DMake(coor.latitude + self.step, coor.longitude - self.step); break;
            case 8: return CLLocationCoordinate2DMake(coor.latitude + self.step, coor.longitude); break;
            case 9: return CLLocationCoordinate2DMake(coor.latitude + self.step, coor.longitude + self.step); break;
            case 4: return CLLocationCoordinate2DMake(coor.latitude, coor.longitude - self.step); break;
            case 5: return self.curlocation; break;
            case 6: return CLLocationCoordinate2DMake(coor.latitude, coor.longitude + self.step); break;
            case 1: return CLLocationCoordinate2DMake(coor.latitude - self.step, coor.longitude - self.step); break;
            case 2: return CLLocationCoordinate2DMake(coor.latitude - self.step, coor.longitude); break;
            case 3: return CLLocationCoordinate2DMake(coor.latitude - self.step, coor.longitude + self.step); break;
            default: break;
        }
        return kCLLocationCoordinate2DInvalid;
    }];
}

- (void)p_newCoordinate2DWithBlock:(CLLocationCoordinate2D (^)(CLLocationCoordinate2D coor))block {
    CLLocationCoordinate2D coor = [self coordinate2DWithText:self.typeField.text];
    if (block) {
        CLLocationCoordinate2D ncoor = block(coor);
        self.typeField.text = [self textWithCoordinate2D:ncoor];
        CLLocationCoordinate2D scoor = [self transformFromToGPSWithCoordinate:ncoor];
        self.statusLabel.text = [self textOfGPXWithCoordinate2D:scoor];
    }
}

- (void)p_printSenderTitle:(UIButton *)sender {
    printf("<!-- %s -->\n", [sender.titleLabel.text UTF8String]);
}

#pragma mark - Actions

- (void)applyButtonAction:(UIButton *)sender {
    self.curlocation = [self coordinate2DWithText:self.typeField.text];
}

- (void)pauseButtonAction:(UIButton *)sender {
    
}

// ↖️
- (void)button7Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:7];
}
// ⬆️
- (void)button8Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:8];
}
// ↗️
- (void)button9Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:9];
}
// ⬅️
- (void)button4Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:4];
}
// 🔄
- (void)button5Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:5];
}
// ➡️
- (void)button6Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:6];
}
// ↙️
- (void)button1Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:1];
}
// ⬇️
- (void)button2Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:2];
}
// ↘️
- (void)button3Action:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self p_newCoordinate2DWithNumber:3];
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
        _typeField.placeholder = @"输入起始坐标(高德)";
        _typeField.textColor = [UIColor grayColor];
        _typeField.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _typeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _typeField.leftViewMode = UITextFieldViewModeAlways;
        _typeField.clearButtonMode = UITextFieldViewModeAlways;
//        _typeField.text = @"39.9106291424,116.3732868433"; // 大悦城
        _typeField.text = @"40.9892484231,117.9441922903"; // 承德
        _curlocation = [self coordinate2DWithText:_typeField.text];
    }
    return _typeField;
}

- (UIButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_applyButton addTarget:self action:@selector(applyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_applyButton setTitle:@"<-应用坐标" forState:UIControlStateNormal];
        [_applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _applyButton.backgroundColor = [UIColor smr_colorWithHexRGB:@"#BBBBBB"];
        _applyButton.layer.cornerRadius = 3;
        _applyButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        _applyButton.layer.borderWidth = 1;
    }
    return _applyButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton addTarget:self action:@selector(pauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pauseButton.backgroundColor = [UIColor smr_colorWithHexRGB:@"#BBBBBB"];
        _pauseButton.layer.cornerRadius = 3;
        _pauseButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        _pauseButton.layer.borderWidth = 1;
    }
    return _pauseButton;
}

@end
