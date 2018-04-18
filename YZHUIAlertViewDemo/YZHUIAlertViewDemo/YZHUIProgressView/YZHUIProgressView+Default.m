//
//  YZHUIProgressView+Default.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView+Default.h"

@implementation YZHUIProgressView (Default)

-(void)progressWithSuccessText:(NSString*)successText
{
    [self progressWithFailText:successText showTimeInterval:1.0];
}

-(void)progressWithFailText:(NSString*)failText
{
    [self progressWithFailText:failText showTimeInterval:1.0];
}


-(void)progressWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *successImage = [UIImage imageNamed:@"success"];
    [self progressShowInView:nil titleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

-(void)progressWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [UIImage imageNamed:@"fail"];
    [self progressShowInView:nil titleText:failText animationImages:@[failImage] showTimeInterval:timeInterval];
}

-(void)updateWithSuccessText:(NSString*)successText
{
    [self updateWithSuccessText:successText showTimeInterval:1.0];
}

-(void)updateWithFailText:(NSString*)failText
{
    [self updateWithFailText:failText showTimeInterval:1.0];
}

-(void)updateWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *successImage = [UIImage imageNamed:@"success"];
    [self updateTitleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

-(void)updateWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [UIImage imageNamed:@"fail"];
    [self updateTitleText:failText animationImages:@[failImage] showTimeInterval:timeInterval];
}

@end
