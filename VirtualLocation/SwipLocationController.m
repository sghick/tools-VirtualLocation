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
@property (strong, nonatomic) UITextField *typeEndField;
@property (strong, nonatomic) UIButton *applyButton;
@property (strong, nonatomic) UIButton *pauseButton;

@property (assign, nonatomic) CLLocationCoordinate2D curlocation;
@property (assign, nonatomic) CLLocationCoordinate2D endlocation;

@property (assign, nonatomic) CGFloat step; ///< 作用于方向移动和点-点移动
@property (assign, nonatomic) NSInteger count; ///< 仅对方向移动有效

@end

@implementation SwipLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationView.backBtnHidden = YES;
    self.navigationView.title = @"定位移动器";
    
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.typeField];
    [self.view addSubview:self.typeEndField];
    [self.view addSubview:self.applyButton];
    [self.view addSubview:self.pauseButton];
    
    self.statusLabel.frame = CGRectMake(20, self.navigationView.bottom + 10, SCREEN_WIDTH - 2*20, 80);
    self.typeField.frame = CGRectMake(20, self.statusLabel.bottom + 10, SCREEN_WIDTH - 2*20, 40);
    self.typeEndField.frame = CGRectMake(20, self.typeField.bottom + 10, SCREEN_WIDTH - 2*20, 40);
    self.applyButton.frame = CGRectMake(20, self.typeEndField.bottom + 10, 200, 40);
    self.pauseButton.frame = CGRectMake(self.applyButton.right + 20, self.typeEndField.bottom + 10, SCREEN_WIDTH - self.applyButton.right - 2*20, 40);
    
    [self strokeControlButtons];
}

- (void)strokeControlButtons {
    NSArray<UIButton *> *array = @[[self buttonWithTitle:@"↖️" action:@selector(buttonAction:) tag:7],
                                   [self buttonWithTitle:@"⬆️" action:@selector(buttonAction:) tag:8],
                                   [self buttonWithTitle:@"↗️" action:@selector(buttonAction:) tag:9],
                                   [self buttonWithTitle:@"⬅️" action:@selector(buttonAction:) tag:4],
                                   [self buttonWithTitle:@"🔄" action:@selector(buttonAction:) tag:5],
                                   [self buttonWithTitle:@"➡️" action:@selector(buttonAction:) tag:6],
                                   [self buttonWithTitle:@"↙️" action:@selector(buttonAction:) tag:1],
                                   [self buttonWithTitle:@"⬇️" action:@selector(buttonAction:) tag:2],
                                   [self buttonWithTitle:@"↘️" action:@selector(buttonAction:) tag:3]];
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

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action tag:(NSInteger)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.numberOfLines = 0;
    btn.tag = tag;
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
    printf("%s\n", [result cStringUsingEncoding:NSUTF8StringEncoding]);
//    printf("<!-- %s -->\n", [result cStringUsingEncoding:NSUTF8StringEncoding]);
    return result;
}

- (CLLocationCoordinate2D)transformFromToGPSWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [SMRUtils transformFromGDToGPSWithCoordinate:coordinate];
}

- (double)randomEnd {
     return arc4random()%10000*0.000001*self.step;
}

#pragma mark - Fast

- (void)o:(NSString *)f t:(NSString *)t {
    CLLocationCoordinate2D fromCoor = [self coordinate2DWithText:f];
    CLLocationCoordinate2D toCoor = [self coordinate2DWithText:t];
    [self newCoordinate2DFromCoor:fromCoor toCoor:toCoor];
}

- (void)o:(NSInteger)f {
    [self newCoordinate2DWithNumber:f];
}

- (void)l:(NSString *)t {
    [self p_sychStatusTextWithCoor:[self coordinate2DWithText:t]];
}

#pragma mark - Functions

- (void)newCoordinate2DWithNumber:(NSInteger)number {
    CLLocationCoordinate2D scoor = [self p_newCoordinate2DWithNumber:number];
    self.typeField.text = [self textWithCoordinate2D:scoor];
}

- (void)newCoordinate2DFromCoor:(CLLocationCoordinate2D)fromCoor toCoor:(CLLocationCoordinate2D)toCoor {
    [self p_newCoordinate2DFromCoor:fromCoor toCoor:toCoor];
}

#pragma mark - Private

/// 计算某个方向的移动轨迹,返回最后一个转换前的点
- (CLLocationCoordinate2D)p_newCoordinate2DWithNumber:(NSInteger)number {
    CLLocationCoordinate2D fromCoor = [self coordinate2DWithText:self.typeField.text];
    CLLocationCoordinate2D toCoor = [self p_newCoordinate2DWithNumber:number fromCoor:fromCoor step:self.step count:self.count];
    [self p_newCoordinate2DFromCoor:fromCoor toCoor:toCoor];
    return toCoor;
}

- (CLLocationCoordinate2D)p_newCoordinate2DWithNumber:(NSInteger)number fromCoor:(CLLocationCoordinate2D)fromCoor step:(double)step count:(NSInteger)count {
    double offset = step*count;
    switch (number) {
        case 7: return CLLocationCoordinate2DMake(fromCoor.latitude + offset, fromCoor.longitude - offset); break;
        case 8: return CLLocationCoordinate2DMake(fromCoor.latitude + offset, fromCoor.longitude); break;
        case 9: return CLLocationCoordinate2DMake(fromCoor.latitude + offset, fromCoor.longitude + offset); break;
        case 4: return CLLocationCoordinate2DMake(fromCoor.latitude, fromCoor.longitude - offset); break;
        case 5: return fromCoor; break;
        case 6: return CLLocationCoordinate2DMake(fromCoor.latitude, fromCoor.longitude + offset); break;
        case 1: return CLLocationCoordinate2DMake(fromCoor.latitude - offset, fromCoor.longitude - offset); break;
        case 2: return CLLocationCoordinate2DMake(fromCoor.latitude - offset, fromCoor.longitude); break;
        case 3: return CLLocationCoordinate2DMake(fromCoor.latitude - offset, fromCoor.longitude + offset); break;
        default: break;
    }
    return kCLLocationCoordinate2DInvalid;
}

/// 计算2个点之间的轨迹
- (void)p_newCoordinate2DFromCoor:(CLLocationCoordinate2D)fromCoor toCoor:(CLLocationCoordinate2D)toCoor {
    double fit = 10000;
    double absla = toCoor.latitude - fromCoor.latitude;
    double abslo = toCoor.longitude - fromCoor.longitude;
    double abspa = hypot(ABS(absla), ABS(abslo));
    NSInteger count = (NSInteger)(abspa/self.step);
    if (count == 0) {
        NSLog(@"两点间距离太近,请设置合适的step");
        return;
    }
    double stepOfLa = absla*fit/count;
    double stepOfLo = abslo*fit/count;
    
    for (int i = 0; i < count; i++) {
        CLLocationCoordinate2D nCoor = CLLocationCoordinate2DMake(fromCoor.latitude + i*stepOfLa/fit,
                                                                  fromCoor.longitude + i*stepOfLo/fit);
        [self p_sychStatusTextWithCoor:nCoor];
    }
}

- (CLLocationCoordinate2D)p_sychStatusTextWithCoor:(CLLocationCoordinate2D)coor {
    CLLocationCoordinate2D scoor = [self transformFromToGPSWithCoordinate:coor];
    self.statusLabel.text = [self textOfGPXWithCoordinate2D:scoor];
    return scoor;
}

- (void)p_printSenderTitle:(UIButton *)sender {
    NSString *firstChar = [sender.titleLabel.text substringToIndex:1];
//    printf("<!-- %s -->\n", [firstChar UTF8String]);
    if (sender.tag == 5) {
        return;
    }
    NSString *lastChar = [[sender.titleLabel.text substringFromIndex:1] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSInteger count = lastChar.integerValue + 1;
    NSString *nTitle = [NSString stringWithFormat:@"%@\n%@", firstChar, @(count)];
    [sender setTitle:nTitle forState:UIControlStateNormal];
}

#pragma mark - Actions
//- (void)applyButtonAction:(UIButton *)sender {
//    self.curlocation = [self coordinate2DWithText:self.typeField.text];
//    self.endlocation = [self coordinate2DWithText:self.typeEndField.text];
//}

- (void)longTravButtonAction:(UIButton *)sender {
    // 长途飞行
    self.step = 0.35;
    _typeField.text = @"40.9856728490,117.9386186600"; // 方向的起点
    _curlocation = [self coordinate2DWithText:_typeField.text];
    _typeEndField.text = @"40.9856728490,117.9386186600";
    _endlocation = [self coordinate2DWithText:_typeEndField.text];
    CLLocationCoordinate2D fromCoor = [self coordinate2DWithText:_typeField.text];
    CLLocationCoordinate2D toCoor = [self coordinate2DWithText:_typeEndField.text];
    [self newCoordinate2DFromCoor:fromCoor toCoor:toCoor];
}

- (void)shortTravButtonAction:(UIButton *)sender {
    // 短途旅游
    self.step = 0.0002;
    self.count = 1;
    NSArray<NSString *> *points = @[@"40.9936538469,117.9403191805",
                                    @"40.9886207882,117.9444766045",
                                    @"40.9886693795,117.9432106018",
                                    @"40.9900015771,117.9407000542",
                                    @"40.9894589831,117.9401475191",
                                    @"40.9871994768,117.9414886236",
                                    @"40.9868107367,117.9427438974",
                                    @"40.9857619370,117.9415047169",
                                    @"40.9856445028,117.9386991262",
                                    @"40.9832957745,117.9427385330",
                                    @"40.9846685758,117.9413169622",
                                    @"40.9819431931,117.9414242506",
                                    @"40.9801329583,117.9375672340",
                                    @"40.9788370103,117.9405552149",
                                    @"40.9799183187,117.9426741600",
                                    @"40.9829353588,117.9431945086",
                                    @"40.9844944463,117.9446053505",
                                    @"40.9832512289,117.9446589947",
                                    @"40.9851464174,117.9462146759",
                                    @"40.9879202596,117.9469656944",
                                    @"40.9893901463,117.9471963644",
                                    @"40.9924998810,117.9469013214",
                                    @"40.9921557119,117.9460966587",
                                    @"40.9950183348,117.9467511177",
                                    @"40.9979537101,117.9442244768",
                                    @"40.9983261897,117.9459625483",
                                    @"41.0008484694,117.9480278492",
                                    @"40.9991156777,117.9444497824",
                                    @"41.0012371267,117.9441440105",
                                    @"41.0008241783,117.9416549206",
                                    @"40.9967714781,117.9417997599",
                                    @"40.9934878390,117.9400938749",];
    NSString *begin = points.firstObject;
    NSString *end = begin;
    for (int i = 0; i < points.count; i++) {
        end = points[i];
        CLLocationCoordinate2D fromCoor = [self coordinate2DWithText:begin];
        CLLocationCoordinate2D toCoor = [self coordinate2DWithText:end];
        [self newCoordinate2DFromCoor:fromCoor toCoor:toCoor];
        begin = end;
    }
}

- (void)buttonAction:(UIButton *)sender {
    [self p_printSenderTitle:sender];
    [self newCoordinate2DWithNumber:sender.tag];
    if (sender.tag == 5) {
        self.typeField.text = [self textWithCoordinate2D:self.curlocation];
        self.typeEndField.text = [self textWithCoordinate2D:self.endlocation];
        [self p_sychStatusTextWithCoor:[self coordinate2DWithText:self.typeField.text]];
        for (UIView *subView in self.view.subviews) {
            if ((subView.tag > 0) && (subView.tag < 10)) {
                [subView removeFromSuperview];
            }
        }
        [self strokeControlButtons];
    }
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
    }
    return _typeField;
}

- (UITextField *)typeEndField {
    if (!_typeEndField) {
        _typeEndField = [[UITextField alloc] init];
        _typeEndField.font = [UIFont systemFontOfSize:15];
        _typeEndField.placeholder = @"输入终点坐标(高德)";
        _typeEndField.textColor = [UIColor grayColor];
        _typeEndField.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _typeEndField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _typeEndField.leftViewMode = UITextFieldViewModeAlways;
        _typeEndField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _typeEndField;
}


- (UIButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_applyButton addTarget:self action:@selector(longTravButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_applyButton setTitle:@"长途/定点计算" forState:UIControlStateNormal];
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
        [_pauseButton addTarget:self action:@selector(shortTravButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pauseButton setTitle:@"短途计算" forState:UIControlStateNormal];
        [_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pauseButton.backgroundColor = [UIColor smr_colorWithHexRGB:@"#BBBBBB"];
        _pauseButton.layer.cornerRadius = 3;
        _pauseButton.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        _pauseButton.layer.borderWidth = 1;
    }
    return _pauseButton;
}

@end
