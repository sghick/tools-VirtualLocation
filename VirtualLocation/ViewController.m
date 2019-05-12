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
                                   [self buttonWithTitle:@"创建" action:@selector(createClick)],
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
    NSString *result = [NSString stringWithFormat:@"高德:%@\n<wpt lat='%@' lon='%@'></wpt>", txt, @(scoor.latitude), @(scoor.longitude)];
    printf("%s\n", [result cStringUsingEncoding:NSUTF8StringEncoding]);
    self.statusLabel.text = result;
}

- (void)BD2GPSBtnClick {
    NSString *txt = self.valueTextField.text;
    NSArray<NSString *> *ls = [txt componentsSeparatedByString:@","];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(ls.firstObject.doubleValue, ls.lastObject.doubleValue);
    CLLocationCoordinate2D scoor = [SMRUtils transformFromBDToGPSWithCoordinate:coor];
    NSString *result = [NSString stringWithFormat:@"百度:\n<wpt lat='%@' lon='%@'></wpt>", @(scoor.latitude), @(scoor.longitude)];
    self.statusLabel.text = result;
}

- (void)createClick {
//    NSArray<NSString *> *gdstrs = @[@"39.8338830351,116.2907552719",
//                                    @"39.8342784928,116.2896233797",
//                                    @"39.8345874425,116.2900042534",
//                                    @"39.8338912738,116.2919837236",
//                                    @"39.8345668459,116.2927347422",
//                                    @"39.8361651241,116.2947678566",
//                                    @"39.8370054410,116.2961143255",
//                                    @"39.8362516278,116.2963718176",
//                                    @"39.8387066393,116.2963610888",
//                                    @"39.8410215195,116.2947732210",
//                                    @"39.8419523924,116.2934106588",
//                                    @"39.8434804793,116.2936413288",
//                                    @"39.8453545018,116.2938344479",
//                                    @"39.8474055711,116.2927132845",
//                                    @"39.8477515286,116.2936145067",
//                                    @"39.8481016028,116.2944567204",
//                                    @"39.8470019519,116.2957173586",
//                                    @"39.8459228766,116.2953901291",
//                                    @"39.8456304525,116.2965005636",
//                                    @"39.8535831204,116.2961786985",
//                                    @"39.8537807928,116.2972140312",
//                                    @"39.8545055867,116.2984049320",
//                                    @"39.8543326252,116.2992149591",
//                                    @"39.8552550815,116.2997353077",
//                                    @"39.8559510336,116.3021117449",
//                                    @"39.8570423052,116.3007920980",
//                                    @"39.8574623372,116.3033777475",
//                                    @"39.8584753449,116.3034850359",
//                                    @"39.8635031012,116.3040107489",
//                                    @"39.8646436629,116.3056683540",
//                                    @"39.8655206884,116.3046276569",
//                                    @"39.8663812331,116.3065588474",
//                                    @"39.8665994557,116.3075512648",
//                                    @"39.8653642246,116.3090264797",
//                                    @"39.8645860176,116.3082271814",
//                                    @"39.8638036842,116.3094878197",
//                                    @"39.8624160499,116.3092678785",
//                                    @"39.8604848445,116.3082593679",
//                                    @"39.8592536212,116.3072508574",
//                                    @"39.8583106292,116.3075083494",
//                                    @"39.8580512012,116.3058561087"];
    
    NSString *title = @"世界公园";
    NSArray<NSString *> *gdstrs = @[@"39.8125166986,116.2904870510",
                                    @"39.8121705636,116.2904173136",
                                    @"39.8121582016,116.2902778387",
                                    @"39.8118285476,116.2906265259",
                                    @"39.8118491510,116.2902027369",
                                    @"39.8115359783,116.2901061773",
                                    @"39.8119233233,116.2896019220",
                                    @"39.8121499603,116.2893229723",
                                    @"39.8120263402,116.2892371416",
                                    @"39.8120510642,116.2891137600",
                                    @"39.8117172890,116.2893927097",
                                    @"39.8116554786,116.2889742851",
                                    @"39.8119356853,116.2888723612",
                                    @"39.8123971998,116.2887328863",
                                    @"39.8126650416,116.2881749868",
                                    @"39.8122364942,116.2883520126",
                                    @"39.8121293570,116.2879443169",
                                    @"39.8129617266,116.2875741720",
                                    @"39.8131183099,116.2874776125",
                                    @"39.8131059481,116.2871825695",
                                    @"39.8116554786,116.2889581919",
                                    @"39.8116637200,116.2883037329",
                                    @"39.8115318576,116.2883359194",
                                    @"39.8116060303,116.2875366211",
                                    @"39.8117997028,116.2871342897",
                                    @"39.8114988920,116.2866890430",
                                    @"39.8112434078,116.2876921892",
                                    @"39.8113134601,116.2870860100",
                                    @"39.8107365574,116.2875741720",
                                    @"39.8106912291,116.2865012884",
                                    @"39.8105181573,116.2866407633",
                                    @"39.8102626695,116.2874507904",
                                    @"39.8098917984,116.2873059511",
                                    @"39.8097970199,116.2868499756",
                                    @"39.8097146037,116.2865120173",
                                    @"39.8100483886,116.2863081694",
                                    @"39.8096692748,116.2872415781",
                                    @"39.8094261463,116.2867534161",
                                    @"39.8091871378,116.2865817547",
                                    @"39.8093808171,116.2874293327",
                                    @"39.8092613129,116.2876170874",
                                    @"39.8094920795,116.2884968519",
                                    @"39.8097805367,116.2882554531",
                                    @"39.8092613129,116.2892103195",
                                    @"39.8094467504,116.2894892693",
                                    @"39.8092860379,116.2896984816",
                                    @"39.8092901588,116.2909591198",
                                    @"39.8089934579,116.2906265259",
                                    @"39.8089563702,116.2904763222",
                                    @"39.8089069199,116.2900847197",
                                    @"39.8084577446,116.2896180153",
                                    @"39.8084082940,116.2892854214",
                                    @"39.8085319206,116.2888938189",
                                    @"39.8082517000,116.2888830900",
                                    @"39.8086637887,116.2879228592",
                                    @"39.8089069199,116.2879604101",
                                    @"39.8087132392,116.2874078751",
                                    @"39.8088945573,116.2872040272",
                                    @"39.8087503270,116.2869036198"];
    
//    NSString *bd = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"gpx"];
//    NSString *str = [[NSString alloc] initWithContentsOfFile:bd encoding:NSUTF8StringEncoding error:nil];
//    printf("%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    printf("%s\n", [doc cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *gpxformat = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<gpx version=\"1.1\"\n    creator=\"GMapToGPX 6.4j - http://www.elsewhere.org/GMapToGPX/\"\n    xmlns=\"http://www.topografix.com/GPX/1/1\"\n    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n    xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">\n        %@\n</gpx>";
    int i = 0;
    for (NSString *txt in gdstrs) {
        NSArray<NSString *> *ls = [txt componentsSeparatedByString:@","];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(ls.firstObject.doubleValue, ls.lastObject.doubleValue);
        CLLocationCoordinate2D scoor = [SMRUtils transformFromGDToGPSWithCoordinate:coor];
        NSString *lostr = [NSString stringWithFormat:@"<wpt lat='%@' lon='%@'></wpt>", @(scoor.latitude), @(scoor.longitude)];
        NSString *result = [NSString stringWithFormat:gpxformat, lostr];
        NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%2d.gpx", title, i]];
        [result writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        printf("%s\n", [result cStringUsingEncoding:NSUTF8StringEncoding]);
        i++;
    }
    
}

- (void)location1Click {
    NSString *coorstr = [NSString stringWithFormat:@"40.1088331591,116.0828089714"];
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
