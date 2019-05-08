//
//  WebViewController.m
//  VirtualLocation
//
//  Created by 丁治文 on 2019/5/8.
//  Copyright © 2019 sumrise. All rights reserved.
//

#import "WebViewController.h"
#import <SafariServices/SafariServices.h>

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationView.backBtnHidden = YES;
    self.navigationView.title = @"坐标在线";
    // Do any additional setup after loading the view.
    UIButton *btn = [SMRNavigationView buttonOfOnlyTextWithText:@"safari" target:self action:@selector(openInSafari)];
    self.navigationView.rightView = btn;
}

- (void)openInSafari {
    SFSafariViewController *web = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.gpsspg.com/maps.htm"]];
    [SMRNavigator presentToViewController:web baseController:self animated:YES];
}

@end
