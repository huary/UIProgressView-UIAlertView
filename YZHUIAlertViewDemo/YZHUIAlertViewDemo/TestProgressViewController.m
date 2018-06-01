//
//  TestProgressViewController.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2018/4/17.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "TestProgressViewController.h"
#import "YZHUIProgressView.h"
#import "YZHUIProgressView+Default.h"

@interface TestProgressViewController ()

/** 注释 */
@property (nonatomic, strong) UIView *testView;

@end

@implementation TestProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupChildView];
}


-(void)_setupChildView
{
    self.view.backgroundColor = WHITE_COLOR;
    
    [self _createBackButton];
    
    CGFloat width = SAFE_WIDTH / 4.0;
    CGFloat space = width * 0.25;
    
    CGFloat x = space;
    CGRect frame = CGRectMake(x, 100, width, 40);
    
    UIButton *btn = [self _createBtnWithTitle:@"simple" frame:frame tag:1];

    frame.origin.x = CGRectGetMaxX(frame) + space;
    btn = [self _createBtnWithTitle:@"update" frame:frame tag:2];

    frame.origin.x = CGRectGetMaxX(frame) + space;
    btn = [self _createBtnWithTitle:@"outEnable" frame:frame tag:3];
    
    frame.origin.x = space;
    frame.origin.y = CGRectGetMaxY(btn.frame) + UI_HEIGHT(20);
    btn = [self _createBtnWithTitle:@"InView" frame:frame tag:4];
    
    UIView *testView = [[UIView alloc] init];
    CGFloat y = CGRectGetMaxY(btn.frame);
    testView.frame = CGRectMake(0, y, SAFE_WIDTH, SAFE_HEIGHT - y);
    testView.backgroundColor = ORANGE_COLOR;
    [self.view addSubview:testView];
    self.testView = testView;
}

-(void)_createBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 20, 40, 40);
    [backBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [backBtn setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(_backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

-(void)_backButtonAction:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIButton*)_createBtnWithTitle:(NSString*)title frame:(CGRect)frame tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.tag = tag;
    btn.backgroundColor = PURPLE_COLOR;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

-(void)_btnAction:(UIButton*)sender
{
    NSLog(@"sender.tag=%ld",sender.tag);
    if (sender.tag == 1) {
        YZHUIProgressView *progressView = [YZHUIProgressView shareProgressView];
        [progressView progressShowTitleText:@"正在请求，请稍后..." showTimeInterval:2];
        progressView.completionBlock = ^(YZHUIProgressView *progressView, NSInteger dismissTag, BOOL finished) {
            NSLog(@"dissMiss finish");
        };
    }
    else if (sender.tag== 2) {
        YZHUIProgressView *progressView = [[YZHUIProgressView alloc] init];
        [progressView progressShowInView:nil titleText:@"正在请求，别着急，请耐心等待..." showTimeInterval:5];
        WEAK_SELF(weakSelf);
        progressView.timeoutBlock = ^(YZHUIProgressView *progressView) {
            [progressView updateWithFailText:@"更新失败"];
            progressView.timeoutBlock = ^(YZHUIProgressView *progressView) {
                [weakSelf _updateAgain:progressView];
            };
        };
    
        progressView.completionBlock = ^(YZHUIProgressView *progressView,NSInteger dismissTag, BOOL finished) {
            NSLog(@"==============dismiss完成");
        };
    }
    else if (sender.tag == 3) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:@"test" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(_testAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat w = SCREEN_WIDTH * 0.5;
        btn.frame = CGRectMake((SCREEN_WIDTH - w)/2 , SCREEN_HEIGHT  * 0.7, w, 100);
        btn.backgroundColor = PURPLE_COLOR;
        [self.view addSubview:btn];
        YZHUIProgressView *shareProgressView  = [YZHUIProgressView shareProgressView];
        [shareProgressView progressShowTitleText:@"正在阻塞中"];
        shareProgressView.outSideUserInteractionEnabled = YES;
    }
    else if (sender.tag == 4) {
        YZHUIProgressView *progressView = [YZHUIProgressView shareProgressView];
        progressView.completionBlock = ^(YZHUIProgressView *progressView, NSInteger dismissTag, BOOL finished) {
//            NSLog(@"supperView=%@",progressView.alertView.showInView.superview);
//            UIView *showInViewTmp = progressView.alertView.showInView;
//            NSLog(@"showInView=%@",showInViewTmp);
        };
        [progressView progressShowInView:self.testView titleText:@"test" showTimeInterval:10];
    }
}

-(void)_updateAgain:(YZHUIProgressView*)progressView
{
    progressView.progressViewStyle = YZHUIProgressViewStyleIndicator;
    [progressView updateTitleText:@"再次更新，请稍后..." showTimeInterval:5];
}

-(void)_testAction:(id)sender
{
    [[YZHUIProgressView shareProgressView] dismiss];
}

-(void)dealloc
{
    NSLog(@"VC=============dealloc");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
