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
}


-(void)test
{
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:@"温馨提示" alertMessage:@"请稍后再试" alertViewStyle:YZHUIAlertViewStyleAlertInfo];
    
    alertView.delayDismissInterval = 5;
    
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"现在更新" attributes:@{NSForegroundColorAttributeName:RED_COLOR,NSFontAttributeName:FONT(20)}];
    
//    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:@"现在更新"];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:RED_COLOR range:NSMakeRange(2, 2)];
//    [attributedString addAttribute:NSFontAttributeName value:FONT(28) range:NSMakeRange(2, 2)];
//
//    [alertView addAlertActionWithTitle:attributedString actionStyle:YZHUIAlertActionStyleDefault actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@",actionModel.actionTitleText);
//    }];
//
//    [alertView addAlertActionWithTitle:@"稍后更新" actionStyle:YZHUIAlertActionStyleDefault actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@",actionModel.actionTitleText);
//    }];
//    
//    alertView.actionCellLayoutStyle = YZHUIAlertActionCellLayoutStyleHorizontal;
//    [alertView addAlertActionWithTitle:@"退出" actionStyle:YZHUIAlertActionStyleCancel actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@",actionModel.actionTitleText);
//    }];
//    
//    [alertView addAlertActionWithTitle:@"详细信息" actionStyle:YZHUIAlertActionStyleConfirm actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@",actionModel.actionTitleText);
//    }];
//
//    [alertView addAlertActionWithTitle:@"删除" actionStyle:YZHUIAlertActionStyleDestructive actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@",actionModel.actionTitleText);
//    }];
    
    
    
    [alertView alertShowInView:nil];
}

-(void)test2
{
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:@"请输入用户名" alertViewStyle:YZHUIAlertViewStyleAlertEdit];

    [alertView addAlertActionWithTitle:@"用户名" actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
    }];
    
    [alertView addAlertActionWithTitle:@"密码" actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
    }];
    
    alertView.coverActionBlock = ^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
        [actionCellInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHAlertActionModel *  _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"obj.text=%@",obj.alertEditText);
        }];
    };
    
    [alertView alertShowInView:nil];
}

-(void)test3
{
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:@"请输入用户名" alertViewStyle:YZHUIAlertViewStyleAlertForce];
    
    [alertView addAlertActionWithTitle:@"用户名" actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
    }];
    
    [alertView addAlertActionWithTitle:@"密码" actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
    }];
    
//    [alertView addAlertActionWithTitle:@"知道了" actionStyle:YZHUIAlertActionStyleDestructive actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitle, alertEditViewActionModelInfo);
//        [alertEditViewActionModelInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHAlertActionModel *_Nonnull obj, BOOL * _Nonnull stop) {
//            NSLog(@"key=%@,obj.text=%@",key, obj.alertEditText);
//        }];
//    }];
    
//    alertView.coverActionBlock = ^(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
//        NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitle, alertEditViewActionModelInfo);
//        [alertEditViewActionModelInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHAlertActionModel *  _Nonnull obj, BOOL * _Nonnull stop) {
//            NSLog(@"obj.text=%@",obj.alertEditText);
//        }];
//    };
    
    alertView.forceActionBlock = ^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionId=%@,actionModel.title=%@,info=%@",actionModel.actionId,actionModel.actionTitleText,actionCellInfo);
        [actionCellInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHAlertActionModel *_Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"key=%@,obj.text=%@",key, obj.alertEditText);
        }];
    };
    //密码框,方法一
    [alertView prepareShowInView:nil];
    UITextField *textField = (UITextField*)[alertView alertCellContentViewForAlertActionModelIndex:2];
    textField.secureTextEntry = YES;
    
    [alertView alertShowInView:nil];
    
    //密码框,方法二
//    UITextField *textField = (UITextField*)[alertView alertCellTextLabelOrTextFieldForAlertActionModelIndex:2];
//    textField.secureTextEntry = YES;

}

-(void)test4
{
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:nil alertViewStyle:YZHUIAlertViewStyleAlertForce];
    alertView.frame =CGRectMake(0, 0, 200, 200);
    alertView.customContentAlertView = [[UIView alloc] init];
    alertView.animateDuration = 0;
//    alertView.customContentAlertView.backgroundColor = RED_COLOR;
    alertView.backgroundColor = BLACK_COLOR;
    [alertView alertShowInView:nil];
}

-(void)test5
{
    YZHUIProgressView *progressView = [YZHUIProgressView shareProgressView];
    [progressView progressShowTitleText:@"正在连接，请稍后..." showTimeInterval:10.0];
//    [progressView progressShowInView:nil titleText:@"正在连接，请稍后..." animationImages:nil showTimeInterval:5];
}

-(void)test6
{
    YZHUIProgressView *progressView = [[YZHUIProgressView alloc] init];
    self.progressView = progressView;
    [self.progressView progressShowInView:nil titleText:@"正在请求，别着急，请耐心等待..." showTimeInterval:2];
    self.progressView.completionBlock = ^(YZHUIProgressView *progressView ,NSInteger dismissTag,BOOL finished) {
        NSLog(@"dissMiss finish");
    };
}

-(void)test7
{
    CGSize size = SCREEN_BOUNDS.size;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((size.width-100)/2, 0, 100, 80);
    btn.backgroundColor = RED_COLOR;
    [btn setTitle:@"test7" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(removeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, SCREEN_HEIGHT-80)];
    self.testView.backgroundColor = PURPLE_COLOR;
    [self.view addSubview:self.testView];
    
    YZHUIProgressView *progressView = [[YZHUIProgressView alloc] init];
//    progressView.contentColor = RED_COLOR;
//    progressView.backgroundColor = CLEAR_COLOR;
    [progressView progressShowInView:self.testView titleText:@"正在测试，请稍后。。。"];
}

-(void)removeAction:(UIButton*)sender
{
    [self.testView removeFromSuperview];
    self.testView = nil;
}

-(void)test8
{
    YZHUIProgressView *progressView = [[YZHUIProgressView alloc] init];
//    YZHUIProgressView *progressView = [YZHUIProgressView shareProgressView];
    
    self.progressView = progressView;
    [self.progressView progressShowInView:nil titleText:@"正在请求，别着急，请耐心等待..." showTimeInterval:25];
    
    [self performSelector:@selector(_updateAction) withObject:nil afterDelay:1];
}

-(void)_updateAction
{
    UIImage *imageOK = [UIImage imageNamed:@"success"];
    UIImage *imageError = [UIImage imageNamed:@"fail"];
    [self.progressView updateTitleText:@"请求成功" animationImages:@[imageOK,imageError] showTimeInterval:1.0];
    
//    [self.progressView progressShowTitleText:@"请求成功" animationImages:@[imageOK] showTimeInterval:1.0];
}

-(void)test9
{
        YZHUIProgressView *progressView = [[YZHUIProgressView alloc] init];
//    YZHUIProgressView *progressView = [YZHUIProgressView shareProgressView];
    
    self.progressView = progressView;
    [self.progressView progressShowInView:nil titleText:@"正在请求，别着急，请耐心等待..." showTimeInterval:5];
    WEAK_SELF(weakSelf);
    self.progressView.timeoutBlock = ^(YZHUIProgressView *progressView) {
        [progressView updateWithFailText:@"更新失败"];
        progressView.timeoutBlock = ^(YZHUIProgressView *progressView) {
            [weakSelf _updateAgain:progressView];
        };
    };
    
    
    self.progressView.completionBlock = ^(YZHUIProgressView *progressView,NSInteger dismissTag, BOOL finished) {
        NSLog(@"==============dismiss完成");
    };
//    [self performSelector:@selector(_updateAction) withObject:nil afterDelay:1];
}

-(void)_updateAgain:(YZHUIProgressView*)progressView
{
    progressView.progressViewStyle = YZHUIProgressViewStyleIndicator;
    [progressView updateTitleText:@"再次更新，请稍后..." showTimeInterval:5];
}

-(void)test10
{
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:@"title" alertMessage:@"message" alertViewStyle:YZHUIAlertViewStyleActionSheet];
    
    [alertView addAlertActionWithTitle:@"1" actionStyle:YZHUIAlertActionStyleDefault actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.actionTitle=%@",actionModel.actionTitleText);
    }];
    
    [alertView addAlertActionWithTitle:@"2" actionStyle:YZHUIAlertActionStyleDefault actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"actionModel.actionTitle=%@",actionModel.actionTitleText);
    }];
    
    [alertView alertShowInView:nil];
}

-(void)test11
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"test" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_testAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 100, SCREEN_WIDTH, 100);
    btn.backgroundColor = PURPLE_COLOR;
    [self.view addSubview:btn];
    YZHUIProgressView *shareProgressView  = [YZHUIProgressView shareProgressView];
    [shareProgressView progressShowTitleText:@"正在阻塞中"];
    shareProgressView.outSideUserInteractionEnabled = YES;
}

-(void)_testAction:(id)sender
{
    [[YZHUIProgressView shareProgressView] dismiss];
}

-(void)test12
{
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:@"提示" alertMessage:@"message" alertViewStyle:YZHUIAlertViewStyleAlertForce];
    alertView.animateDuration = 0;
    [alertView addAlertActionWithCustomCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
        CGSize contentSize = actionCell.cellMaxSize;
        UIButton *btn= [self _createFunctionBtn:@"测试1"];
        btn.backgroundColor= PURPLE_COLOR;
        btn.frame = CGRectMake(10, 0, contentSize.width/2-20, 100);
//        btn.userInteractionEnabled = NO;
        
        contentSize = CGSizeMake(contentSize.width, 60);
        actionCell.cellFrame = CGRectMake(0, 0, contentSize.width/2, 100);
        
        return btn;
    } actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
        NSLog(@"1==================actionModel=%@,alertEditViewActionModelInfo=%@",actionModel,actionCellInfo);
    }].actionAfterStillShow = YES;
    
    
//    [alertView addAlertActionWithCustomCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
//        CGSize contentSize = actionCell.cellMaxSize;
//        UIButton *btn= [self _createFunctionBtn:@"测试2"];
//        btn.backgroundColor= BROWN_COLOR;
//        btn.frame = CGRectMake(10, 0, contentSize.width-20, 80);
//
//        contentSize = CGSizeMake(contentSize.width, 60);
//        actionCell.cellFrame = CGRectMake(contentSize.width/2, 0, contentSize.width, 80);
//        return btn;
//    } actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
//        NSLog(@"2==================actionModel=%@,alertEditViewActionModelInfo=%@",actionModel,actionCellInfo);
//    }];
    
    alertView.actionCellLayoutStyle = YZHUIAlertActionCellLayoutStyleHorizontal;
    
    alertView.backgroundColor = RED_COLOR;
    [alertView alertShowInView:nil];
    
//    [UIView animateWithDuration:0.2 animations:^{
//        alertView.transform = CGAffineTransformMakeTranslation(0, -100);
//    }];

}

-(UIButton*)_createFunctionBtn:(NSString*)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = PURPLE_COLOR;
    
    return btn;
}

-(void)test13
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(100, 200, 200, 100);
    view.backgroundColor = RED_COLOR;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    
    UIView *testView = [[UIView alloc] init];
    testView.frame = CGRectMake(100, 200, 200, 100);
    testView.backgroundColor = PURPLE_COLOR;
    [[UIApplication sharedApplication].keyWindow addSubview:testView];
    
//    [UIView animateWithDuration:10 animations:^{
//        testView.transform = CGAffineTransformMakeTranslation(0, -100);
//    }];
    
    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:nil alertViewStyle:YZHUIAlertViewStyleAlertForce];
    alertView.frame =CGRectMake(100, 100, 200, 200);
    alertView.customContentAlertView = [[UIView alloc] init];
    alertView.animateDuration = 0;
    alertView.customContentAlertView.backgroundColor = RED_COLOR;
    alertView.backgroundColor = BLACK_COLOR;
    [alertView alertShowInView:nil];
    
//    alertView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:10 animations:^{
        alertView.transform = CGAffineTransformMakeTranslation(0, -100);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self test];
//    [self test2];
//    [self test3];
//    [self test4];
//    [self test5];
//    [self test6];
    
//    [self test7];
    
//    [self test8];
    
//    [self test9];
    //sheet
//    [self test10];
    
//    [self test11];
    
//    [self test12];
    
//    [self test13];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
