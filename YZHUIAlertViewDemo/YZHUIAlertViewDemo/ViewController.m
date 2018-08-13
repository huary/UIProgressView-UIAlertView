//
//  ViewController.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/4/22.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "ViewController.h"
#import "YZHUIAlertView.h"
#import "YZHUIProgressView.h"
#import "YZHUIProgressView+Default.h"
#import "TestAlertViewController.h"
#import "TestProgressViewController.h"

#import "YZHUITextView.h"

@interface ViewController ()

@property (nonatomic,strong) YZHUIProgressView *progressView;

@property (nonatomic,strong) UIView *testView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpChildView];
}

-(UIButton*)_createTestBtnWithTitle:(NSString*)title tag:(NSInteger)tag frame:(CGRect)frame color:(UIColor*)color
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.frame = frame;
    btn.backgroundColor = color;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_btnAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)_btnAction:(UIButton*)sender
{
    if (sender.tag == 1) {
        TestAlertViewController *testAlertVC = [[TestAlertViewController alloc] init];
        [self presentViewController:testAlertVC animated:YES completion:nil];
    }
    else {
        TestProgressViewController *testProgressVC = [[TestProgressViewController alloc] init];
        [self presentViewController:testProgressVC animated:YES completion:nil];
    }
}

-(void)setUpChildView
{
    CGFloat w = self.view.bounds.size.width * 0.6;
    CGFloat x = (self.view.bounds.size.width - w)/2;
    CGFloat h = 40;
    CGRect frame = CGRectMake(x, 200, w, h);
    UIButton *testAlertBtn = [self _createTestBtnWithTitle:@"UIAlertDemo" tag:1 frame:frame color:RED_COLOR];
    [self.view addSubview:testAlertBtn];
    
    frame = CGRectMake(x, 300, w, h);
    UIButton *testProgressBtn = [self _createTestBtnWithTitle:@"UIProgressDemo" tag:2 frame:frame color:PURPLE_COLOR];
    [self.view addSubview:testProgressBtn];
    
    
    x = 10;
    CGFloat y = 350;
    w = self.view.bounds.size.width - 2 * x;
    h = UI_HEIGHT(100);
    YZHUITextView *textView = [[YZHUITextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
//    UITextField *textView = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    textView.backgroundColor = GROUP_TABLEVIEW_BG_COLOR;
    textView.placeholder = @"placeHolder-1";
    textView.textColor = RED_COLOR;
    textView.font = FONT(20);
    
//    textView.text = @"placeHolder";
//    textView.placeholder = @"hello world";
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:@"hello world" attributes:@{NSFontAttributeName:FONT(20),NSForegroundColorAttributeName:BROWN_COLOR}];
    
    NSAttributedString *attrPlaceHolder = [[NSAttributedString alloc] initWithString:@"placeHorder-2" attributes:@{NSFontAttributeName:FONT(18),NSForegroundColorAttributeName:PURPLE_COLOR}];
    
    textView.attributedPlaceholder = attrPlaceHolder;
    textView.placeholder = @"placeHolder-3";
//    textView.attributedText = attrText;
    [self.view addSubview:textView];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
