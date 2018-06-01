//
//  YZHUIAlertView.h
//  yxx_ios
//
//  Created by yuan on 2017/4/11.
//  Copyright © 2017年 GDtech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZHUIAlertViewStyle)
{
    //如下所有的都不能支持YZHUIAlertActionStyleHeadTitle和YZHUIAlertActionStyleHeadMessage，由控件本身来负责
    /*点击周边是可以取消的，或者在规定的时间内消失掉
     *ActionStyle 不支持YZHUIAlertActionStyleTextEdit
     */
    YZHUIAlertViewStyleAlertInfo        = 0,
    /*点击周边可以消失，但是没有规定的时间消失，是一种编辑的View,但是不仅仅是，可以包含Info的
     *ActionStyle支持所有
     */
    YZHUIAlertViewStyleAlertEdit        = 1,
    /*这种是一种比较严重的错误警告或者提示点击确定或者消失的
     *ActionStyle支持所有
     */
    YZHUIAlertViewStyleAlertForce       = 2,
    /*是从底部的选项框
     *ActionStyle 不支持 YZHUIAlertActionStyleCancel、YZHUIAlertActionStyleTextEdit
     */
    YZHUIAlertViewStyleActionSheet      = 3,
    /*是从顶部的提示框
     *不可以支持任何的ActionStyle，下同
     */
    YZHUIAlertViewStyleTopInfoTips      = 4,
    //是从顶部的错误提示框
    YZHUIAlertViewStyleTopWarningTips   = 5,
};

typedef NS_ENUM(NSInteger, YZHUIAlertActionStyle)
{
    YZHUIAlertActionStyleDefault        = 0,
    //不能指定如下两种格式的，这个由控件本身来负责，只可以指定字体，字体颜色，背景色，
    YZHUIAlertActionStyleHeadTitle      = 1,
    YZHUIAlertActionStyleHeadMessage    = 2,
    
    YZHUIAlertActionStyleCancel         = 3, //字体可以修改，颜色不可以修改，为蓝色，可以进行阵列排布
    YZHUIAlertActionStyleConfirm        = 4, //可以进行阵列排布
    
    YZHUIAlertActionStyleTextEdit       = 5, //是一种文字编辑的，TextField的控件
    
    YZHUIAlertActionStyleDestructive    = 6, //字体可以修改，颜色不可以修改，为红色,可以进行阵列排布
    YZHUIAlertActionStyleCustomView     = 7, //自定义的customView
//    YZHUIAlertActionStyleTextView       = 8, //是一种文字编辑的，UITextView的控件
};

typedef NS_ENUM(NSInteger, YZHUIAlertActionCellLayoutStyle)
{
    //default
    YZHUIAlertActionCellLayoutStyleVertical      = 0,
    YZHUIAlertActionCellLayoutStyleHorizontal    = 1,
};

typedef NS_ENUM(NSInteger, YZHUIAlertActionTextStyle)
{
    YZHUIAlertActionTextStyleNull       = -1,
    YZHUIAlertActionTextStyleNormal     = 0,
    YZHUIAlertActionTextStyleAttribute  = 1,
};

@class YZHAlertActionModel;
/********************************************************************************
 *UIAlertActionCellProtocol
 ********************************************************************************/
@protocol UIAlertActionCellProtocol <NSObject>

//这里的cellFrame只接受其中的x,width,height，y坐标会自己计算
@property (nonatomic, assign) CGRect cellFrame;
@property (nonatomic, assign, readonly) CGSize cellMaxSize;
@property (nonatomic, assign, readonly) NSInteger cellIndex;

@end


@class YZHUIAlertView;
typedef UIView*(^YZHUIAlertActionCellCustomViewBlock)(YZHAlertActionModel *actionModel, UIView <UIAlertActionCellProtocol>*actionCell);
typedef void(^YZHUIAlertDidShowBlock)(YZHUIAlertView *alertView);
typedef void(^YZHUIAlertDismissCompletionBlock)(YZHUIAlertView *alertView, BOOL finished);


/*
 *actionCellInfo中的object 要么是YZHAlertActionModel，要么是UIView<UIAlertActionCellProtocol>的对象
 */
typedef void(^YZHUIAlertActionBlock)(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo);


/********************************************************************************
 *YZHAlertActionModel
 ********************************************************************************/
@interface YZHAlertActionModel : NSObject

//根据这个actionId可以获取到Edit的textField
@property (nonatomic, copy) NSString *actionId;
//actionTitle是NSString或者NSAttributedString,如果是edit的style，则actionTitle就是placeholder
@property (nonatomic, strong) id actionTitleText;

@property (nonatomic, copy) YZHUIAlertActionBlock actionBlock;
@property (nonatomic, assign) YZHUIAlertActionStyle actionStyle;
//自定义的cell的block
@property (nonatomic, copy) YZHUIAlertActionCellCustomViewBlock customCellBlock;

//alertEditText是NSString或者NSAttributedString
@property (nonatomic, strong) id alertEditText;

//default is NO,点击了action后，alertview就dismiss了，如果为YES的话，则不会
@property (nonatomic, assign) BOOL actionAfterStillShow;

//根据actionTitleTex来进行判断
-(YZHUIAlertActionTextStyle)textStyle;
@end


/********************************************************************************
 *YZHUIAlertView
 ********************************************************************************/
@interface YZHUIAlertView : UIView

@property (nonatomic, copy) UIColor *coverColor;
@property (nonatomic, assign) CGFloat coverAlpha;

@property (nonatomic, copy) YZHUIAlertActionBlock coverActionBlock;
//这是是在force的style的情况下没有提供action的时候，控件会自动生成action，这个action的block需要开发者指定如下
@property (nonatomic, copy) YZHUIAlertActionBlock forceActionBlock;
//显示完成的回调
@property (nonatomic, copy) YZHUIAlertDidShowBlock didShowBlock;
//
@property (nonatomic, copy) YZHUIAlertDismissCompletionBlock dismissCompletionBlock;

//这个只针对alert的style才有效
@property (nonatomic, assign) YZHUIAlertActionCellLayoutStyle actionCellLayoutStyle;

/*
 *指定为weak，是怕出现循环应用的问题，可以在dimss时界面循环引用，但是如果没有调用dismiss时
 *或者调用removeFromSupperView(已在removefromsupperview上做解除循环引用)等其他的方法时没法解除循环应用，
 *为了保险起见使用weak(这里支持使用strong，不会出现循环引用问题)
*/
@property (nonatomic, strong) UIView *customContentAlertView;

-(instancetype)initWithTitle:(id)alertTitle alertViewStyle:(YZHUIAlertViewStyle)alertViewStyle;

-(instancetype)initWithTitle:(id)alertTitle alertMessage:(id)alertMessage alertViewStyle:(YZHUIAlertViewStyle)alertViewStyle;
//这种是不需要加入id的
-(YZHAlertActionModel *)addAlertActionWithTitle:(id)actionTitle actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock;
//这种是需要加入id的
-(YZHAlertActionModel *)addAlertActionWithActionId:(NSString *)actionId actionTitle:(id)actionTitle actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock;

-(YZHAlertActionModel *)addAlertActionWithCustomCellBlock:(YZHUIAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHUIAlertActionBlock)actionBlock;

//以actionModel的方式添加
-(YZHAlertActionModel *)addAlertActionWithActionModel:(YZHAlertActionModel*)actionModel;

-(void)alertShowInView:(UIView*)inView;

-(void)alertShowInView:(UIView *)inView animated:(BOOL)animated;

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame;

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame animated:(BOOL)animated;

-(void)dismiss;

-(void)dismissAnimated:(BOOL)animated;

-(UIView*)getShowInView;

+(NSArray<YZHUIAlertView*>*)alertViewsForTag:(NSInteger)tag inView:(UIView*)inView;

+(NSInteger)alertViewCountForTag:(NSInteger)tag inView:(UIView*)inView;

//default is NO
@property (nonatomic, assign) BOOL outSideUserInteractionEnabled;

//只针对YZHUIAlertViewStyleAlertInfo有效
@property (nonatomic, assign) NSTimeInterval delayDismissInterval;
//还可以设置如下属性
//public,<=0时没有动画效果
@property (nonatomic, assign) CGFloat animateDuration;

//height
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellHeadTitleHeight;
@property (nonatomic, assign) CGFloat cellHeadMessageHeight;
//如果是竖线，此值就是宽度，这个值其实就是线的”宽度“ lineWidth
@property (nonatomic, assign) CGFloat cellSeparatorLineWidth;

//color
@property (nonatomic, copy) UIColor *cellBackgroundColor;
@property (nonatomic, copy) UIColor *cellHighlightColor;
@property (nonatomic, copy) UIColor *cellSeparatorLineColor;
@property (nonatomic, copy) UIColor *cellEditBackgroundColor;
@property (nonatomic, copy) UIColor *cellHeadTitleBackgroundColor;
@property (nonatomic, copy) UIColor *cellHeadMessageBackgroundColor;

//textColor
@property (nonatomic, copy) UIColor *cellTextColor;
@property (nonatomic, copy) UIColor *cellEditTextColor;
@property (nonatomic, copy) UIColor *cellHeadTitleTextColor;
@property (nonatomic, copy) UIColor *cellHeadMessageTextColor;
//only for tips
@property (nonatomic, copy) UIColor *cellHeadTitleHighlightTextColor;

//textFont
@property (nonatomic, copy) UIFont *cellTextFont;
@property (nonatomic, copy) UIFont *cellEditTextFont;
@property (nonatomic, copy) UIFont *cellHeadTitleTextFont;
@property (nonatomic, copy) UIFont *cellHeadMessageTextFont;

@property (nonatomic, copy) UIFont *cellCancelTextFont;
@property (nonatomic, copy) UIFont *cellConfirmTextFont;
@property (nonatomic, copy) UIFont *cellDestructiveTextFont;
//only for tips
@property (nonatomic, copy) UIFont *cellHeadTitleHighlightTextFont;

@property (nonatomic, assign) BOOL cellEditSecureTextEntry;

//image
@property (nonatomic, copy) NSString *cellHeadImageName;
@property (nonatomic, copy) NSString *cellHeadHighlightImageName;

//YZHUIAlertViewStyleActionSheet
@property (nonatomic, assign) CGFloat sheetCancelCellTopLineWidth;
//default is clearColor
@property (nonatomic, copy) UIColor *sheetCancelCellTopLineColor;

@end

@interface YZHUIAlertView (YZHUIAlertViewAttributes)

//如下方法为特殊用法，如果不是特别要求的话，可以不用
-(YZHAlertActionModel*)alertActionModelForModelIndex:(NSInteger)index;
//调用这些方法的前提是调用了show之后或者prepareShow
-(UIView*)prepareShowInView:(UIView*)inView;

-(UILabel*)alertTextLabelForAlertActionModel:(YZHAlertActionModel*)actionModel;
-(UITextField*)alertEditTextFieldForAlertActionModel:(YZHAlertActionModel*)actionModel;
-(UIView*)alertCustomCellSubViewForAlertActionModel:(YZHAlertActionModel*)actionModel;

-(UIView*)alertCellContentViewForAlertActionModelIndex:(NSInteger)index;

-(NSDictionary*)getAllAlertEditViewActionModelInfo;

-(NSDictionary*)getAllAlertCustomCellViewInfo;

-(NSDictionary*)getAllAlertActionCellInfo;

@end
