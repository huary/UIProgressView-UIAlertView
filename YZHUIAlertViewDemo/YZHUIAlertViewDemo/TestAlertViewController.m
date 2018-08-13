//
//  TestAlertViewController.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2018/4/17.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "TestAlertViewController.h"
#import "YZHUIAlertView.h"

@interface TestAlertViewController ()

@end

@implementation TestAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupChildView];
}

//-(void)viewSafeAreaInsetsDidChange
//{
//    [super viewSafeAreaInsetsDidChange];
//}

//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    self.view.frame = self.view.safeAreaLayoutGuide.layoutFrame;
//}

-(void)_setupChildView
{
    self.view.backgroundColor = WHITE_COLOR;//RGB_WITH_INT_WITH_NO_ALPHA(0X666666);
    
    [self _createBackButton];
    
    CGFloat width = SAFE_WIDTH / 4.0;
    CGFloat space = width * 0.25;
    
    CGFloat x = space;
    CGRect frame = CGRectMake(x, 100, width, 40);
    
    UIButton *btn = [self _createBtnWithTitle:@"Info" frame:frame tag:1];
    
    frame.origin.x = CGRectGetMaxX(frame) + space;
    btn = [self _createBtnWithTitle:@"Edit" frame:frame tag:2];
    
    frame.origin.x = CGRectGetMaxX(frame) + space;
    btn = [self _createBtnWithTitle:@"Custom" frame:frame tag:3];
    
    frame.origin.x = x;
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    btn = [self _createBtnWithTitle:@"Custom2" frame:frame tag:4];
    
    frame.origin.x = CGRectGetMaxX(frame) + space;
    btn = [self _createBtnWithTitle:@"Sheet" frame:frame tag:5];
    
    frame.origin.x = CGRectGetMaxX(frame) + space;
    btn = [self _createBtnWithTitle:@"attribute" frame:frame tag:6];
    
    frame.origin.x = x;
    frame.origin.y = CGRectGetMaxY(frame) + 20;
    btn = [self _createBtnWithTitle:@"tips" frame:frame tag:7];
}

-(void)_createBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, STATUS_BAR_HEIGHT, 40, 40);
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

-(UIButton*)_createFunctionBtn:(NSString*)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = PURPLE_COLOR;
    return btn;
}

-(void)_btnAction:(UIButton*)sender
{
    NSLog(@"sender.tag=%ld",sender.tag);
    YZHUIAlertView *alertView = nil;
    if (sender.tag == 1) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:@"温馨提示" alertMessage:@"请稍后再试" alertViewStyle:YZHUIAlertViewStyleAlertInfo];
        
        alertView.delayDismissInterval = 2;
    }
    else if (sender.tag == 2) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:@"请输入用户名" alertViewStyle:YZHUIAlertViewStyleAlertForce];
        
//        alertView.cellEditTextFont = FONT(32);
//        alertView.cellEditTextColor = PURPLE_COLOR;
//        alertView.cellEditBackgroundColor = BLUE_COLOR;
        
        [alertView addAlertActionWithTitle:@"用户名" actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
            return NO;
        }];
        
//        NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:RED_COLOR,NSBackgroundColorAttributeName:YELLOW_COLOR}];
        NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:@"密码" attributes:nil];
        
        [alertView addAlertActionWithTitle:attrTitle actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionModel.title=%@,info=%@",actionModel.actionTitleText, actionCellInfo);
            return NO;
        }];
        
        [alertView addAlertActionWithTitle:@"read" actionStyle:YZHUIAlertActionStyleTextViewRead actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            return NO;
        }].cellContentViewAttributedBlock = ^CGSize(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
//            actionCell.textView.editable = YES;
            return CGSizeMake(500, 90);
        };
        
        YZHAlertActionModel *writeModel = [alertView addAlertActionWithTitle:@"write" actionStyle:YZHUIAlertActionStyleTextViewWrite actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            
            return NO;
        }];
        writeModel.cellContentViewAttributedBlock = ^CGSize(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            return CGSizeMake(500, 40);
        };
        writeModel.cellContentViewMaxSizeAttributedBlock = ^CGSize(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            return CGSizeMake(500, 120);
        };
//        writeModel.cellContentViewUpdateAttributedBlock = ^CGSize(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
//            actionCell.textView.font = FONT(8);
//            return CGSizeZero;
//        };
        
        
        [alertView addAlertActionWithTitle:@"RW" actionStyle:YZHUIAlertActionStyleTextViewRW actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            
            return NO;
        }];
        
        alertView.forceActionBlock = ^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionId=%@,actionModel.title=%@,info=%@",actionModel.actionId,actionModel.actionTitleText,actionCellInfo);
            [actionCellInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHAlertActionModel *_Nonnull obj, BOOL * _Nonnull stop) {
                NSString *text = obj.alertEditText;
                if ([obj.alertEditText isKindOfClass:[NSAttributedString class]]) {
                    text = ((NSAttributedString*)obj.alertEditText).string;
                }
                NSLog(@"key=%@,obj.text=%@",key, text);
            }];
            return YES;
        };
        
        [alertView prepareShowInView:nil];
        UITextField *textField = (UITextField*)[alertView alertCellContentViewForAlertActionModelIndex:2];
        textField.secureTextEntry = YES;
    }
    else if (sender.tag == 3) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:@"提示" alertMessage:@"message" alertViewStyle:YZHUIAlertViewStyleAlertForce];
        alertView.animateDuration = 0;
        [alertView addAlertActionWithCustomCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            CGSize contentSize = actionCell.cellMaxSize;
            UIButton *btn= [self _createFunctionBtn:@"测试1"];
            btn.backgroundColor= PURPLE_COLOR;
            btn.frame = CGRectMake(10, 10, contentSize.width/2-20, 40);
            btn.userInteractionEnabled = NO;
            contentSize = CGSizeMake(contentSize.width, 60);
            actionCell.cellFrame = CGRectMake(0, 0, contentSize.width/2, 60);
            return btn;
        } actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"1==================actionModel=%@,alertEditViewActionModelInfo=%@",actionModel,actionCellInfo);
            return NO;
        }];
        
        [alertView addAlertActionWithCustomCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            CGSize contentSize = actionCell.cellMaxSize;
            UIButton *btn= [self _createFunctionBtn:@"测试2"];
            btn.backgroundColor= BROWN_COLOR;
            btn.frame = CGRectMake(10, 10, contentSize.width/2-20, 40);

//            contentSize = CGSizeMake(contentSize.width, 60);
            actionCell.cellFrame = CGRectMake(0, 0, contentSize.width, 60);
            return btn;
        } actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"2==================actionModel=%@,alertEditViewActionModelInfo=%@",actionModel,actionCellInfo);
            return NO;
        }];
        
        [alertView addCustomAlertActionWithStyle:YZHUIAlertActionStyleCustomCell | YZHUIAlertActionStyleConfirm customCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            CGSize contentSize = actionCell.cellMaxSize;
            UIButton *btn= [self _createFunctionBtn:@"确定"];
            btn.userInteractionEnabled = NO;
            btn.backgroundColor= PURPLE_COLOR;
            btn.frame = CGRectMake(10, 10, contentSize.width-20, 40);
            
            contentSize = CGSizeMake(contentSize.width, 60);
            actionCell.cellFrame = CGRectMake(0, 0, contentSize.width, 60);
            return btn;
        } actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"2==================actionModel=%@,alertEditViewActionModelInfo=%@",actionModel,actionCellInfo);
            return YES;
        }];
        
//        alertView.actionCellLayoutStyle = YZHUIAlertActionCellLayoutStyleHorizontal;
        
        alertView.backgroundColor = RED_COLOR;
    }
    else if (sender.tag == 4) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:nil alertViewStyle:YZHUIAlertViewStyleAlertInfo];
        alertView.frame =CGRectMake(0, 0, 200, 200);
        alertView.customContentAlertView = [[UIView alloc] init];
        alertView.animateDuration = 0;
        alertView.delayDismissInterval = 2.0;
        alertView.backgroundColor = BLACK_COLOR;
    }
    else if (sender.tag == 5) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:@"title" alertMessage:@"message" alertViewStyle:YZHUIAlertViewStyleActionSheet];
        
        [alertView addAlertActionWithTitle:@"1" actionStyle:YZHUIAlertActionStyleDefault actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionModel.actionTitle=%@",actionModel.actionTitleText);
            return YES;
        }];
        
        [alertView addAlertActionWithTitle:@"2" actionStyle:YZHUIAlertActionStyleConfirm actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionModel.actionTitle=%@",actionModel.actionTitleText);
            return YES;
        }];
        [alertView addAlertActionWithTitle:@"3" actionStyle:YZHUIAlertActionStyleDestructive actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionModel.actionTitle=%@",actionModel.actionTitleText);
            return YES;
        }];
        
        [alertView addAlertActionWithTitle:@"4" actionStyle:YZHUIAlertActionStyleTextEdit actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionModel.actionTitle=%@",actionModel.actionTitleText);
            return NO;
        }];
        
        
        YZHAlertActionModel *actionModel = [alertView addAlertActionWithTitle:@"5" actionStyle:YZHUIAlertActionStyleTextViewWrite actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            
            return NO;
        }];
        
        actionModel.cellContentViewAttributedBlock = ^CGSize(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
//            actionCell.textView.editable = YES;
            CGFloat height = actionCell.textView.contentSize.height;
            height = MAX(height, 36);
            return CGSizeMake(CGFLOAT_MAX, height);
        };
//
        actionModel.cellContentViewMaxSizeAttributedBlock = ^CGSize(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            return CGSizeMake(CGFLOAT_MAX, 100);
        };
        

        
//        [alertView addCustomAlertActionWithStyle:YZHUIAlertActionStyleCustomCell customCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
//            CGSize contentSize = actionCell.cellMaxSize;
//            UIButton *btn= [self _createFunctionBtn:@"确定"];
//            btn.userInteractionEnabled = NO;
//            btn.backgroundColor= PURPLE_COLOR;
//            btn.frame = CGRectMake(10, 10, contentSize.width-20, 40);
//
//            contentSize = CGSizeMake(contentSize.width, 60);
//            actionCell.cellFrame = CGRectMake(0, 0, contentSize.width, 60);
//            return btn;
//        } actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
//            YZHAlertActionModel *editModel = [actionCellInfo objectForKey:@(5)];
//            NSLog(@"actionModel.actionTitle-----custom-1=%@,alertEditText=%@",actionCellInfo,editModel.alertEditText);
//            return YES;
//        }];
//        alertView.forceActionBlock = ^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
//            YZHAlertActionModel *editModel = [actionCellInfo objectForKey:@(5)];
//            NSLog(@"actionModel.actionTitle-----custom-2=%@,alertEditText=%@",actionCellInfo,editModel.alertEditText);
//            return YES;
//        };
        
        [alertView addCustomSheetLastActionWithCustomCellBlock:^UIView *(YZHAlertActionModel *actionModel, UIView<UIAlertActionCellProtocol> *actionCell) {
            CGSize contentSize = actionCell.cellMaxSize;
            UIButton *btn= [self _createFunctionBtn:@"取消"];
            btn.userInteractionEnabled = NO;
            btn.backgroundColor= PURPLE_COLOR;
            btn.frame = CGRectMake(10, 10, contentSize.width-20, 40);

            actionCell.cellFrame = CGRectMake(0, 0, contentSize.width, 60);
            return btn;
        } actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            YZHAlertActionModel *editModel = [actionCellInfo objectForKey:@(5)];
            NSLog(@"actionModel.actionTitle-----custom-2=%@,alertEditText=%@",actionCellInfo,editModel.alertEditText);
            return YES;
        }];
        
        [alertView alertShowInView:nil];
        return;
    }
    else if (sender.tag == 6) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:@"提示" alertMessage:@"message" alertViewStyle:YZHUIAlertViewStyleAlertForce];
        
        NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:@"现在更新"];
        [attributedString addAttribute:NSForegroundColorAttributeName value:RED_COLOR range:NSMakeRange(2, 2)];
        [attributedString addAttribute:NSFontAttributeName value:FONT(28) range:NSMakeRange(2, 2)];
//        [attributedString addAttribute:NSFontAttributeName value:FONT(20) range:NSMakeRange(4, attributedString.length-4)];
        
        [alertView addAlertActionWithTitle:attributedString actionStyle:YZHUIAlertActionStyleDefault actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *alertEditViewActionModelInfo) {
            NSLog(@"actionModel.title=%@",actionModel.actionTitleText);
            return NO;
        }];
        alertView.forceActionBlock = ^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
            NSLog(@"actionId=%@,actionModel.title=%@,info=%@",actionModel.actionId,actionModel.actionTitleText,actionCellInfo);
            [actionCellInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHAlertActionModel *_Nonnull obj, BOOL * _Nonnull stop) {
                NSLog(@"key=%@,obj.text=%@",key, obj.alertEditText);
            }];
            return YES;
        };
    }
    else if (sender.tag == 7) {
        alertView = [[YZHUIAlertView alloc] initWithTitle:@"tips" alertViewStyle:YZHUIAlertViewStyleTopInfoTips];
//        alertView.backgroundColor = RED_COLOR;
//        alertView.animateDuration = 0;
    }
    [alertView alertShowInView:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
