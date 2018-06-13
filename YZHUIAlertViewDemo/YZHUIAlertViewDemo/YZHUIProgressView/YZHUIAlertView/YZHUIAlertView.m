//
//  YZHUIAlertView.m
//  yxx_ios
//
//  Created by yuan on 2017/4/11.
//  Copyright © 2017年 GDtech. All rights reserved.
//

#import "YZHUIAlertView.h"
#import "NSKeyboardManager.h"


#define ACTION_CELL_SUBVIEW_TAG             (1234)

#define TOP_ALERT_VIEW_MIN_HEIGHT           (64)
#define TOP_ALERT_VIEW_HEIGHT               (100)


#if TOP_ALERT_VIEW_HEIGHT < TOP_ALERT_VIEW_MIN_HEIGHT
#error "TOP_ALERT_VIEW_HEIGHT must be greater than TOP_ALERT_VIEW_MIN_HEIGHT(64)"
#endif

#define TOP_ALERT_VIEW_SHIFT_HEIGHT         (16)

#define YZHUIALERT_VIEW_STYLE_IS_TIPS(STYLE)    (((STYLE) == YZHUIAlertViewStyleTopInfoTips )|| ((STYLE) == YZHUIAlertViewStyleTopWarningTips))

#define YZHUIALERT_VIEW_STYLE_IS_ALERT(STYLE)   (((STYLE) == YZHUIAlertViewStyleAlertInfo )|| ((STYLE) == YZHUIAlertViewStyleAlertEdit) || ((STYLE) == YZHUIAlertViewStyleAlertForce))
#define YZHUIALERT_VIEW_STYLE_IS_SHEET(STYLE)   ((STYLE) == YZHUIAlertViewStyleActionSheet)

#define YZHUIALERT_ACTION_STYLE_IS_HEAD(ACTION_STYLE)   ((ACTION_STYLE) == YZHUIAlertActionStyleHeadTitle || (ACTION_STYLE) == YZHUIAlertActionStyleHeadMessage)

#define YZHUIALERT_ACTION_STYLE_IS_SHEET_SUPPORT(ACTION_STYLE)  ((!YZHUIALERT_ACTION_STYLE_IS_HEAD(ACTION_STYLE)) && (ACTION_STYLE) != YZHUIAlertActionStyleCancel && (ACTION_STYLE) != YZHUIAlertActionStyleTextEdit)

#define YZHUIALERT_ACTION_STYLE_CAN_LAYOUT(ACTION_STYLE)        ((ACTION_STYLE) == YZHUIAlertActionStyleCancel || (ACTION_STYLE) == YZHUIAlertActionStyleConfirm || (ACTION_STYLE) == YZHUIAlertActionStyleDestructive)

#define YZHUIALERT_ACTION_STYLE_SHOULD_LAYOUT(ACTION_STYLE,LAYOUT_STYLE)     (YZHUIALERT_ACTION_STYLE_CAN_LAYOUT(ACTION_STYLE) && (LAYOUT_STYLE) == YZHUIAlertActionCellLayoutStyleHorizontal)

#define USE_KEYBOARD_MANAGER                    (1)

static const CGFloat defaultYZHUIAlertViewStyleAlertAnimateDuration             = 0.8;
static const CGFloat defaultYZHUIAlertViewStyleTopTipsAnimateDuration           = 0.3;
static const CGFloat defaultYZHUIAlertViewStyleActionSheetAnimateDuration       = 0.3;
//static const CGFloat defaultYZHUIAlertViewStyleCustomViewAnimateDuration        = 0.3;


static const CGFloat UIAlertViewWidthWithScreenWidthRatio           = 0.7;
static const CGFloat UIAlertViewLandscapeWidthWithScreenWidthRatio  = 0.4;
static const CGFloat UIAlertViewTextFieldWidthWithBaseWidthRatio    = 0.9;
static const CGFloat UIAlertViewTextFieldHeightWithBaseHeightRatio  = 0.8;
static const CGFloat defaultYZHUIAlertViewCellHeight                = 50;
static const CGFloat defaultYZHUIAlertViewHeadTitleHeight           = 50;//55;
static const CGFloat defaultYZHUIAlertViewHeadMessageHeight         = 50;
static const CGFloat defaultYZHUIAlertViewCellSeparatorLineWidth    = 1.0;

static const CGFloat defaultYZHUIAlertViewCellTextFontSize              = 16.0;
static const CGFloat defaultYZHUIAlertViewCellHeadTitleTextFontSize     = 18.0;
static const CGFloat defaultYZHUIAlertViewCellHeadMessageTextFontSize   = 16.0;

static const CGFloat defaultYZHUIAlertViewCellCancelConfirmDestructiveTextFontSize     = 18.0;

static const CGFloat defaultYZHUIAlertViewCoverAlpha                    = 0.1;

static const CGFloat defaultYZHUIAlertViewSheetCancelCellTopLineWidth   = 8.0;

typedef NS_ENUM(NSInteger, YZHUIAlertTipsStyleSubViewTag)
{
    YZHUIAlertTipsStyleSubViewTagImageView = 1,
    YZHUIAlertTipsStyleSubViewTagLabelView = 2,
};

/********************************************************************************
 *NSText
 ********************************************************************************/
@interface NSText : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;

-(instancetype)initWithTextObj:(id)textObj;
@end


@implementation NSText

-(instancetype)initWithTextObj:(id)textObj
{
    self = [super init];
    if (self) {
        [self _setupValueWithTextObj:textObj];
    }
    return self;
}

-(void)_setupValueWithTextObj:(id)textObj
{
    if ([textObj isKindOfClass:[NSString class]]) {
        self.text = (NSString*)textObj;
    }
    else if ([textObj isKindOfClass:[NSAttributedString class]])
    {
        self.attributedText = (NSAttributedString*)textObj;
    }
}

@end

/********************************************************************************
 *YZHAlertActionModel
 ********************************************************************************/
@implementation YZHAlertActionModel

-(YZHUIAlertActionTextStyle)textStyle
{
    id checkObj = self.actionTitleText;
    
    if ([checkObj isKindOfClass:[NSString class]]) {
        return YZHUIAlertActionTextStyleNormal;
    }
    else if ([checkObj isKindOfClass:[NSAttributedString class]])
    {
        return YZHUIAlertActionTextStyleAttribute;
    }
    else
    {
        return YZHUIAlertActionTextStyleNull;
    }
}

//-(NSText*)actionTitleTextToNSText
//{
//    YZHUIAlertActionTextStyle textStyle = self.textStyle;
//    NSText *text = [[NSText alloc] init];
//    if (textStyle == YZHUIAlertActionTextStyleNormal) {
//        text.text = (NSString*)self.actionTitleText;
//    }
//    else if (textStyle == YZHUIAlertActionTextStyleAttribute)
//    {
//        text.attributedText = (NSAttributedString*)self.actionTitleText;
//    }
//    return text;
//}

@end

typedef NS_ENUM(NSInteger, NSAlertActionCellType)
{
    NSAlertActionCellTypeTextLabel  = 0,
    NSAlertActionCellTypeTextField  = 1,
    NSAlertActionCellTypeCustomView = 2,
};


/********************************************************************************
 *YZHUIAlertActionCell
 ********************************************************************************/
@interface YZHUIAlertActionCell : UIControl <UIAlertActionCellProtocol>

@property (nonatomic, assign, readonly) NSAlertActionCellType cellType;

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UITextField *editTextField;
@property (nonatomic, strong, readonly) UIView *customView;

@property (nonatomic, assign) YZHUIAlertActionTextStyle textStyle;

@property (nonatomic, copy, readonly) UIColor *normalColor;
@property (nonatomic, copy) UIColor *highlightColor;

@property (nonatomic, assign) CGRect cellFrame;
@property (nonatomic, assign, readonly) CGSize cellMaxSize;
@property (nonatomic, assign, readonly) NSInteger cellIndex;
@property (nonatomic, strong) YZHAlertActionModel *actionModel;

@property (nonatomic, weak) YZHUIAlertView *alertView;

//这里传进来的frame中的size是alertCell最大可以的size
-(instancetype)initWithAlertActionModel:(YZHAlertActionModel*)actionModel cellFrame:(CGRect)cellFrame atCellIndex:(NSInteger)cellIndex;

@end

@implementation YZHUIAlertActionCell

-(instancetype)init
{
    self = [super init];
    if (self) {
        _cellIndex = -1;
    }
    return self;
}

-(instancetype)initWithAlertActionModel:(YZHAlertActionModel*)actionModel cellFrame:(CGRect)cellFrame atCellIndex:(NSInteger)cellIndex
{
    self = [super init];
    if (self) {
        _cellFrame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width-cellFrame.origin.x, cellFrame.size.height);
        _cellMaxSize = cellFrame.size;
        _cellIndex = cellIndex;
        self.clipsToBounds = YES;
        self.actionModel = actionModel;
    }
    return self;
}

-(UILabel*)_createAlertHeadLabelWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel == nil || !YZHUIALERT_ACTION_STYLE_IS_HEAD(actionModel.actionStyle)) {
        return nil;
    }
    UILabel *headLabel = [[UILabel alloc] init];
    headLabel.textAlignment = NSTextAlignmentCenter;
    headLabel.tag = ACTION_CELL_SUBVIEW_TAG;
    headLabel.numberOfLines = 0;
    if (self.textStyle == YZHUIAlertActionTextStyleAttribute) {
        headLabel.attributedText = actionModel.actionTitleText;
    }
    else
    {
        headLabel.text = actionModel.actionTitleText;
    }
    
    [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:headLabel];
    return headLabel;
}

-(UILabel*)_createAlertInfoCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel == nil || actionModel.actionStyle == YZHUIAlertActionStyleTextEdit) {
        return nil;
    }
    
    UILabel *infoCell = [[UILabel alloc] init];
    infoCell.textAlignment = NSTextAlignmentCenter;
    infoCell.tag = ACTION_CELL_SUBVIEW_TAG;
    infoCell.numberOfLines = 0;

    if (self.textStyle == YZHUIAlertActionTextStyleAttribute) {
        infoCell.attributedText = actionModel.actionTitleText;
    }
    else
    {
        infoCell.text = actionModel.actionTitleText;
        CGFloat fontSize= defaultYZHUIAlertViewCellTextFontSize;
        if (actionModel.actionStyle == YZHUIAlertActionStyleDefault) {
            infoCell.textColor = BLACK_COLOR;
            infoCell.font = FONT(fontSize);
        }
        else if (actionModel.actionStyle == YZHUIAlertActionStyleCancel)
        {
            infoCell.textColor = BLUE_COLOR;
            infoCell.font = BOLD_FONT(fontSize);
        }
        else if (actionModel.actionStyle == YZHUIAlertActionStyleDestructive)
        {
            infoCell.textColor = RED_COLOR;
            infoCell.font = BOLD_FONT(fontSize);
        }
    }

    [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:infoCell];
    return infoCell;
}

-(UITextField*)_createAlertEditCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel.actionStyle != YZHUIAlertActionStyleTextEdit) {
        return nil;
    }
    UITextField *editCell = [[UITextField alloc] init];
    editCell.tag = ACTION_CELL_SUBVIEW_TAG;

    if (self.textStyle == YZHUIAlertActionTextStyleAttribute) {
        editCell.attributedPlaceholder = actionModel.actionTitleText;
    }
    else
    {
        editCell.placeholder = actionModel.actionTitleText;
    }
    
    [self addSubview:editCell];
    return editCell;
}

-(UIView*)_createAlertCustomCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel.actionStyle != YZHUIAlertActionStyleCustomView) {
        return nil;
    }
    if (!actionModel.customCellBlock) {
        return nil;
    }
    UIView *customView = actionModel.customCellBlock(actionModel, self);
    customView.tag = ACTION_CELL_SUBVIEW_TAG;
    [self addSubview:customView];
    
    [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
//    if (actionModel.actionBlock) {
//        [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    return customView;
}

-(void)_controlAction:(UIControl*)control
{
    [self.alertView endEditing:YES];
    if (YZHUIALERT_ACTION_STYLE_IS_HEAD(self.actionModel.actionStyle)) {
        if (self.actionModel.actionBlock) {
            self.actionModel.actionBlock(self.actionModel, [self.alertView getAllAlertActionCellInfo]);
        }
    }
    else
    {
        if (self.actionModel && self.actionModel.actionBlock) {
            self.actionModel.actionBlock(self.actionModel,[self.alertView getAllAlertActionCellInfo]);
        }
        if (!self.actionModel.actionAfterStillShow) {
            [self.alertView dismiss];
        }
    }
}

-(void)_createAlertActionViewForActionModel:(YZHAlertActionModel*)actionModel
{
    if (!actionModel) {
        return;
    }
    
    if (YZHUIALERT_ACTION_STYLE_IS_HEAD(actionModel.actionStyle)) {
        _textLabel = [self _createAlertHeadLabelWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextLabel;
    }
    else if (actionModel.actionStyle == YZHUIAlertActionStyleTextEdit)
    {
        _editTextField = [self _createAlertEditCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextField;
    }
    else if (actionModel.actionStyle == YZHUIAlertActionStyleCustomView)
    {
        _customView = [self _createAlertCustomCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeCustomView;
    }
    else
    {
        _textLabel = [self _createAlertInfoCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextLabel;
    }
}

-(void)setActionModel:(YZHAlertActionModel *)actionModel
{
    _actionModel = actionModel;
    self.textStyle = actionModel.textStyle;
    [self _createAlertActionViewForActionModel:actionModel];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *subView = [self viewWithTag:ACTION_CELL_SUBVIEW_TAG];
    CGRect frame = self.frame;
    
    CGFloat width = frame.size.width * UIAlertViewTextFieldWidthWithBaseWidthRatio;
    CGFloat height = frame.size.height * UIAlertViewTextFieldHeightWithBaseHeightRatio;
    CGFloat x = (frame.size.width - width)/2;
    CGFloat y = (frame.size.height - height)/2;
    
    if (self.actionModel.actionStyle == YZHUIAlertActionStyleTextEdit) {
        subView.frame = CGRectMake(x, y, width, height);
    }
    else if (self.actionModel.actionStyle == YZHUIAlertActionStyleCustomView)
    {
//        subView.frame = self.bounds;
    }
    else
    {
        subView.frame = CGRectMake(x, y, width, height);
    }
}

#pragma mark override
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _normalColor = self.backgroundColor;
    if (self.highlightColor) {
        self.backgroundColor = self.highlightColor;
    }
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        self.backgroundColor = self.normalColor;
        return NO;
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.backgroundColor = self.normalColor;
}

-(void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.backgroundColor = self.normalColor;
}

@end


@interface YZHUIAlertView ()

@property (nonatomic, weak) UIView *showInView;

//cover
@property (nonatomic, strong) UIButton *cover;

//effectview
@property (nonatomic, strong) UIView *effectView;

//alertviewStyle
@property (nonatomic, assign) YZHUIAlertViewStyle alertViewStyle;

@property (nonatomic, strong) id alertTitle;
@property (nonatomic, strong) id alertMessage;

@property (nonatomic, strong) NSMutableArray *actionModels;

//YZHUIAlertViewStyleActionSheet
@property (nonatomic, strong) YZHAlertActionModel *cancelModel;

@property (nonatomic, assign) BOOL isCreate;

@property (nonatomic, strong) NSKeyboardManager *keyboardManager;

@end

@implementation YZHUIAlertView

-(instancetype)initWithTitle:(id)alertTitle alertViewStyle:(YZHUIAlertViewStyle)alertViewStyle
{
    self = [self initWithTitle:alertTitle alertMessage:nil alertViewStyle:alertViewStyle];
    if (self) {
    }
    return self;
}

-(instancetype)initWithTitle:(id)alertTitle alertMessage:(id)alertMessage alertViewStyle:(YZHUIAlertViewStyle)alertViewStyle
{
    self = [super init];
    if (self) {
        self.alertTitle = alertTitle;
        self.alertMessage = alertMessage;
        self.alertViewStyle = alertViewStyle;
        [self _setupDefaultValue];
        [self _setupChildView];
    }
    return self;
}

-(UIView*)effectView
{
    if (_effectView == nil) {
        if (SYSTEMVERSION_NUMBER > 8.0) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            _effectView = effectView;
        }
        else
        {
            UIToolbar *toolBar = [[UIToolbar alloc] init];
            toolBar.barStyle = UIBarStyleDefault;
            _effectView = toolBar;
        }
    }
    return _effectView;
}

-(void)_setupDefaultValue
{
    self.delayDismissInterval = 0;
    
    //cover
    self.coverColor = BLACK_COLOR;
    self.coverAlpha = defaultYZHUIAlertViewCoverAlpha;
    
    //height
    self.cellHeight = defaultYZHUIAlertViewCellHeight;
    self.cellHeadTitleHeight = defaultYZHUIAlertViewHeadTitleHeight;
    self.cellHeadMessageHeight = defaultYZHUIAlertViewHeadMessageHeight;
    self.cellSeparatorLineWidth = defaultYZHUIAlertViewCellSeparatorLineWidth/SCREEN_SCALE;
    
    //color
    self.cellBackgroundColor = [WHITE_COLOR colorWithAlphaComponent:0.8];
    self.cellHighlightColor = CLEAR_COLOR;
    self.cellSeparatorLineColor = RGB_WITH_INT_WITH_NO_ALPHA(0x999999);//[BLACK_COLOR colorWithAlphaComponent:0.8];
    self.cellEditBackgroundColor = GROUP_TABLEVIEW_BG_COLOR;
    self.cellHeadTitleBackgroundColor = self.cellBackgroundColor;
    self.cellHeadMessageBackgroundColor = self.cellBackgroundColor;
    
    //textColor
    self.cellTextColor = BLACK_COLOR;
    self.cellEditTextColor = BLACK_COLOR;
    self.cellHeadTitleTextColor = BLACK_COLOR;
    self.cellHeadMessageTextColor = BLACK_COLOR;
    
    //font
    self.cellTextFont = FONT(defaultYZHUIAlertViewCellTextFontSize);
    self.cellEditTextFont = FONT(defaultYZHUIAlertViewCellTextFontSize);
    self.cellHeadTitleTextFont = BOLD_FONT(defaultYZHUIAlertViewCellHeadTitleTextFontSize);
    self.cellHeadMessageTextFont = FONT(defaultYZHUIAlertViewCellHeadMessageTextFontSize);
    
    self.cellCancelTextFont = BOLD_FONT(defaultYZHUIAlertViewCellCancelConfirmDestructiveTextFontSize);
    self.cellConfirmTextFont = self.cellCancelTextFont;
    self.cellDestructiveTextFont = self.cellCancelTextFont;
    
    self.cellEditSecureTextEntry = NO;
    
    if (YZHUIALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        self.animateDuration = defaultYZHUIAlertViewStyleTopTipsAnimateDuration;
        
        self.cellHeadTitleTextColor = BLACK_COLOR;
        self.cellHeadTitleTextFont = FONT(defaultYZHUIAlertViewCellTextFontSize);
        
        self.cellHeadTitleHighlightTextFont = self.cellHeadTitleTextFont;
        self.cellHeadTitleHighlightTextColor = RED_COLOR;
        
        self.cellHeadImageName = @"alert_info";
        self.cellHeadHighlightImageName = @"chat_warning";
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle))
    {
        self.animateDuration = defaultYZHUIAlertViewStyleAlertAnimateDuration;
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        //only for sheet
        self.sheetCancelCellTopLineWidth = defaultYZHUIAlertViewSheetCancelCellTopLineWidth;
        self.sheetCancelCellTopLineColor = CLEAR_COLOR;

        self.animateDuration = defaultYZHUIAlertViewStyleActionSheetAnimateDuration;
    }
}

-(void)_setupChildView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    
    if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        self.backgroundColor = CLEAR_COLOR;

        [self addSubview:self.effectView];
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle))
    {
        self.backgroundColor = WHITE_COLOR;
        UILabel *label = [[UILabel alloc] init];
        label.tag = YZHUIAlertTipsStyleSubViewTagLabelView;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [self addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = YZHUIAlertTipsStyleSubViewTagImageView;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle))
    {
        self.backgroundColor = CLEAR_COLOR;
        [self addSubview:self.effectView];
    }
}

-(UIButton*)cover
{
    if (YZHUIALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        return nil;
    }
    if (self.outSideUserInteractionEnabled) {
        return _cover;
    }
    if (_cover == nil) {
        _cover = [UIButton buttonWithType:UIButtonTypeCustom];
        _cover.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cover.backgroundColor = self.coverColor;
        _cover.alpha = self.coverAlpha;
        [_cover addTarget:self action:@selector(_coverClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cover;
}

-(void)_coverClickAction:(UIButton*)sender
{
    [self endEditing:YES];
    if (self.alertViewStyle == YZHUIAlertViewStyleAlertForce) {
        return;
    }
    if (self.coverActionBlock) {
        self.coverActionBlock(nil, [self getAllAlertActionCellInfo]);
    }
    [self dismiss];
}

-(void)setAlertTitle:(id)alertTitle
{
    _alertTitle = alertTitle;
    if (alertTitle) {
        WEAK_SELF(weakSelf);
        NSText *text = [[NSText alloc] initWithTextObj:alertTitle];
        if (IS_AVAILABLE_NSSTRNG(text.text)) {
            [self addAlertActionWithoutCheckWithTitle:alertTitle actionStyle:YZHUIAlertActionStyleHeadTitle actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
                [weakSelf endEditing:YES];
            }];
        }
        else if (text.attributedText)
        {
            [self addAlertActionWithoutCheckWithTitle:alertTitle actionStyle:YZHUIAlertActionStyleHeadTitle actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
                [weakSelf endEditing:YES];
            }];
        }
    }
}

-(void)setAlertMessage:(id)alertMessage
{
    _alertMessage = alertMessage;
    if (alertMessage) {
        WEAK_SELF(weakSelf);
        
        NSText *text = [[NSText alloc] initWithTextObj:alertMessage];
        if (IS_AVAILABLE_NSSTRNG(text.text)) {
            [self addAlertActionWithoutCheckWithTitle:alertMessage actionStyle:YZHUIAlertActionStyleHeadMessage actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
                [weakSelf endEditing:YES];
            }];
        }
        else if (text.attributedText)
        {
            [self addAlertActionWithoutCheckWithTitle:alertMessage actionStyle:YZHUIAlertActionStyleHeadMessage actionBlock:^(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
                [weakSelf endEditing:YES];
            }];
        }

    }
}

-(void)setCustomContentAlertView:(UIView *)customContentAlertView
{
    if (_customContentAlertView != customContentAlertView) {
        _customContentAlertView = customContentAlertView;
        if (customContentAlertView) {
            [self addSubview:customContentAlertView];
        }
    }
//    self.animateDuration = defaultYZHUIAlertViewStyleCustomViewAnimateDuration;
}

-(void)setOutSideUserInteractionEnabled:(BOOL)outSideUserInteractionEnabled
{
    _outSideUserInteractionEnabled = outSideUserInteractionEnabled;
    if (self.cover && outSideUserInteractionEnabled) {
        [self.cover removeFromSuperview];
        self.cover = nil;
    }
}

/*如果为横线，则size为（width，0）
 *如果为竖线，则size为（0， height）
 */
-(CAShapeLayer*)_createAlertSeparatorLineWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)lineColor
{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointZero];
    if (size.width > 0) {
        [linePath addLineToPoint:CGPointMake(size.width, 0)];
    }
    else
    {
        [linePath addLineToPoint:CGPointMake(0, size.height)];
    }
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = lineWidth;//self.cellSeparatorHeight;
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor= lineColor.CGColor;//self.cellSeparatorColor.CGColor;
    return lineLayer;
}

-(CALayer*)_createSeparatorLineWithFrame:(CGRect)frame lineColor:(UIColor*)lineColor
{
    CALayer *lineLayer = [[CALayer alloc] init];
    lineLayer.frame = frame;
    lineLayer.backgroundColor = lineColor.CGColor;
    return lineLayer;
}

-(void)_addLayoutActionForFoce
{
    if (self.alertViewStyle == YZHUIAlertViewStyleAlertForce) {
        __block BOOL needToAdd = YES;
//        __block BOOL isAllEdit = YES;
        [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!YZHUIALERT_ACTION_STYLE_IS_HEAD(obj.actionStyle))
            {
//                if (obj.actionStyle != YZHUIAlertActionStyleTextEdit) {
//                    isAllEdit = NO;
//                }
                if (YZHUIALERT_ACTION_STYLE_CAN_LAYOUT(obj.actionStyle)) {
                    needToAdd = NO;
                }
            }
        }];
        if (needToAdd /*&& isAllEdit*/) {
            NSInteger index = self.actionModels.count;
            NSString *cancelId = [NSString stringWithFormat:@"%@",@(index)];
            NSString *confirmId = [NSString stringWithFormat:@"%@",@(index+1)];
            [self addAlertActionWithActionId:cancelId actionTitle:NSLOCAL_STRING(@"取消") actionStyle:YZHUIAlertActionStyleCancel actionBlock:self.forceActionBlock];
            [self addAlertActionWithActionId:confirmId actionTitle:NSLOCAL_STRING(@"确定") actionStyle:YZHUIAlertActionStyleConfirm actionBlock:self.forceActionBlock];
            self.actionCellLayoutStyle = YZHUIAlertActionCellLayoutStyleHorizontal;
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGSize showInViewSize = self.showInView.bounds.size;
    if (self.customContentAlertView) {
        self.customContentAlertView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    
    CGFloat contentHeight = size.height;
    if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
        self.effectView.frame = self.bounds;
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        
        self.frame = CGRectMake(0, showInViewSize.height - contentHeight, showInViewSize.width, contentHeight);
        self.effectView.frame = self.bounds;
    }
}

-(BOOL)_haveTransformYAnimated
{
    return self.animateDuration > 0;
}

-(void)_createAlertActionCellWithShowInView:(UIView*)showInView;
{
    if (self.isCreate) {
        return;
    }
    self.isCreate = YES;
    self.showInView = showInView;
    CGSize showInViewSize = showInView.bounds.size;
    CGFloat widthRatio = UIAlertViewWidthWithScreenWidthRatio;
    if (UIInterfaceOrientationIsLandscape(STATUS_BAR_ORIENTATION)) {
        widthRatio = UIAlertViewLandscapeWidthWithScreenWidthRatio;
    }
    CGFloat contentWidth = showInViewSize.width * widthRatio;
    
    CGFloat contentHeight = 0;
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero) == NO && YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle) == NO) {
        contentWidth = self.bounds.size.width;
        contentHeight = self.bounds.size.height;
    }
    if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        contentWidth = showInViewSize.width;
        contentHeight = 0;
    }
    
    if (self.customContentAlertView) {
        self.customContentAlertView.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    }
    
    if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle) || YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        if (self.customContentAlertView == nil) {
            [self _addLayoutActionForFoce];
        }
        __block CGFloat totalY = 0;
        __block CGFloat totalX = 0;
        __block CGFloat cTotalX = 0;
        __block CGFloat lastY = 0;
        
        CGFloat cellHeight = self.cellHeight;
        CGFloat headTitleHeight = self.cellHeadTitleHeight;
        CGFloat headMessageHeight = self.cellHeadMessageHeight;
        CGFloat lineHeight = self.cellSeparatorLineWidth;
        UIColor *lineColor = self.cellSeparatorLineColor;
        
        if (self.customContentAlertView == nil) {
            NSInteger cnt = self.actionModels.count;
            [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGRect cellFrame = CGRectMake(totalX, totalY, contentWidth, contentHeight);
                YZHUIAlertActionCell *cell = [[YZHUIAlertActionCell alloc] initWithAlertActionModel:obj cellFrame:cellFrame atCellIndex:idx];
                cell.alertView = self;
                
                if (cell.cellType == NSAlertActionCellTypeTextLabel) {
                    cell.backgroundColor = self.cellBackgroundColor;
                    if (obj.textStyle != YZHUIAlertActionTextStyleAttribute) {
                        if (obj.actionStyle == YZHUIAlertActionStyleHeadTitle) {
                            cell.textLabel.font = self.cellHeadTitleTextFont;
                            cell.textLabel.textColor = self.cellHeadTitleTextColor;
                            cell.backgroundColor = self.cellHeadTitleBackgroundColor;
                        }
                        else if (obj.actionStyle == YZHUIAlertActionStyleHeadMessage)
                        {
                            cell.textLabel.font = self.cellHeadMessageTextFont;
                            cell.textLabel.textColor =self.cellHeadMessageTextColor;
                            cell.backgroundColor = self.cellHeadMessageBackgroundColor;
                        }
                        else
                        {
                            cell.highlightColor = self.cellHighlightColor;
                            if (obj.actionStyle == YZHUIAlertActionStyleCancel) {
                                cell.textLabel.font = self.cellCancelTextFont;
                            }
                            else if (obj.actionStyle == YZHUIAlertActionStyleConfirm)
                            {
                                cell.textLabel.font = self.cellConfirmTextFont;
                            }
                            else if (obj.actionStyle == YZHUIAlertActionStyleDestructive)
                            {
                                cell.textLabel.font = self.cellDestructiveTextFont;
                            }
                            else
                            {
                                cell.textLabel.font =self.cellTextFont;
                            }
                            
                            if (obj.actionStyle != YZHUIAlertActionStyleCancel && obj.actionStyle != YZHUIAlertActionStyleDestructive) {
                                cell.textLabel.textColor = self.cellTextColor;
                            }
                        }
                    }
                }
                else if (cell.cellType == NSAlertActionCellTypeTextField)
                {
                    cell.backgroundColor = self.cellBackgroundColor;
                    if (cell.textStyle != YZHUIAlertActionTextStyleAttribute) {
                        cell.editTextField.font = self.cellTextFont;
                        cell.editTextField.textColor = self.cellTextColor;
                        cell.editTextField.backgroundColor = self.cellEditBackgroundColor;
                    }
                    cell.editTextField.secureTextEntry = self.cellEditSecureTextEntry;
                }
                else if (cell.cellType == NSAlertActionCellTypeCustomView)
                {
                    if (cell.backgroundColor == nil) {
                        cell.backgroundColor = self.cellBackgroundColor;
                    }
                }
                
                CGFloat x = 0;
                CGFloat y = totalY;
                CGFloat width = contentWidth;
                CGFloat height = cellHeight;
                
                BOOL haveBottomLine = YES;
                BOOL haveVerticalLine = NO;
                
                if (cell.cellType == NSAlertActionCellTypeCustomView) {
                    x = cell.cellFrame.origin.x;
                    width = cell.cellFrame.size.width;
                    height = cell.cellFrame.size.height;
                    
                    if (cTotalX == 0) {
                        lastY = totalY;
                    }
                    y = lastY;
                    
                    CGFloat totalYTmp = MAX(totalY, lastY + height);
                    
                    cTotalX = x + width;
                    //如果偏移量大于contentWidth的话，则从下一行开始。
                    if (cTotalX > contentWidth) {
                        x = 0;
                        y = totalY;
                        totalY += height;
                        lastY = totalY;
                    }
                    else {
                        totalY = totalYTmp;
                    }
                    cTotalX = 0;
                }
                else
                {
                    CGFloat attributeCellHeight = -1;
                    if (cell.cellType == NSAlertActionCellTypeTextLabel && obj.textStyle == YZHUIAlertActionTextStyleAttribute) {
                        NSAttributedString *attributeString = (NSAttributedString*)obj.actionTitleText;
                        NSDictionary *dict = [attributeString attributesAtIndex:0 effectiveRange:NULL];
                        CGSize labelSize = [attributeString.string boundingRectWithSize:CGSizeMake(width * UIAlertViewTextFieldWidthWithBaseWidthRatio, showInViewSize.height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading  attributes:dict context:nil].size;
                        attributeCellHeight = labelSize.height / UIAlertViewTextFieldHeightWithBaseHeightRatio;
                    }
                    
                    if (YZHUIALERT_ACTION_STYLE_SHOULD_LAYOUT(obj.actionStyle, self.actionCellLayoutStyle))
                    {
                        BOOL neetLayoutModel = NO;
                        if (totalX == 0) {
                            if (idx + 1 < cnt) {
                                YZHAlertActionModel *nextModel = self.actionModels[idx+1];
                                if (YZHUIALERT_ACTION_STYLE_SHOULD_LAYOUT(nextModel.actionStyle, self.actionCellLayoutStyle)) {
                                    neetLayoutModel = YES;
                                }
                            }
                        }
                        else
                        {
                            if (idx >= 1 ) {
                                YZHAlertActionModel *prevModel = self.actionModels[idx-1];
                                if (YZHUIALERT_ACTION_STYLE_SHOULD_LAYOUT(prevModel.actionStyle, self.actionCellLayoutStyle)) {
                                    neetLayoutModel = YES;
                                }
                            }
                        }
                        
                        if (neetLayoutModel) {
                            haveBottomLine = NO;
                            x = totalX;
                            
                            if (x == 0) {
                                lastY = totalY;
                                totalY += height;
                                haveVerticalLine = YES;
                            }
                            y = lastY;
                            width = (contentWidth - lineHeight)/2;
                            totalX = x + width;
                            if (totalX > contentWidth) {
                                totalX = 0;
                                if (idx+1 < cnt) {
                                    haveBottomLine = YES;
                                }
                            }
                        }
                        else
                        {
                            totalY += height;
                        }
                    }
                    else if (obj.actionStyle == YZHUIAlertActionStyleHeadTitle) {
                        height = headTitleHeight;
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        haveBottomLine = NO;
                        totalY += height;
                    }
                    else if (obj.actionStyle == YZHUIAlertActionStyleHeadMessage)
                    {
                        height = headMessageHeight;
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        haveBottomLine = YES;
                        totalY += height;
                    }
                    else
                    {
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        totalY += height;
                    }
                }
                
                if (idx+1 == cnt) {
                    haveBottomLine = NO;
                }
                
                cell.frame = CGRectMake(x, y, width, height);
                [self addSubview:cell];
                
                if (haveBottomLine || haveVerticalLine) {
                    CGFloat lineHeightTmp = lineHeight;
                    UIColor *lineColorTmp = lineColor;
                    if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
                        if (idx == cnt - 2) {
                            lineHeightTmp = self.sheetCancelCellTopLineWidth;
                            lineColorTmp = self.sheetCancelCellTopLineColor;
                        }
                    }
                    
                    CALayer *lineLayer = nil;
                    if (haveBottomLine) {
                        CGRect frame = CGRectMake(0, totalY, contentWidth, lineHeightTmp);
                        lineLayer = [self _createSeparatorLineWithFrame:frame lineColor:lineColorTmp];
                        totalY += lineHeightTmp;
                    }
                    else
                    {
                        CGRect frame = CGRectMake(x+width, y, lineHeightTmp, cellHeight);
                        lineLayer = [self _createSeparatorLineWithFrame:frame lineColor:lineColorTmp];
                        totalX += lineHeightTmp;
                    }
                    [self.layer addSublayer:lineLayer];
                }
            }];
            contentHeight = totalY;
        }
        
        if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
            if ([self _haveTransformYAnimated]) {
                self.frame = CGRectMake((showInViewSize.width - contentWidth)/2, -contentHeight, contentWidth, contentHeight);
            }
            else
            {
                self.frame =  CGRectMake((showInViewSize.width - contentWidth)/2, (showInViewSize.height - contentHeight)/2, contentWidth, contentHeight);
            }
//            if (self.alertViewStyle == YZHUIAlertViewStyleAlertInfo && self.delayDismissInterval > 0) {
//                [self performSelector:@selector(dismiss) withObject:nil afterDelay:self.delayDismissInterval];
//            }
        }
        else if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
        {
            if ([self _haveTransformYAnimated]) {
                self.frame = CGRectMake(0, showInViewSize.height, showInViewSize.width, contentHeight);
            }
            else
            {
                self.frame = CGRectMake(0, showInViewSize.height - contentHeight, showInViewSize.width, contentHeight);
            }
        }
        self.effectView.frame = self.bounds;
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle))
    {
        self.frame = CGRectMake(0, -TOP_ALERT_VIEW_HEIGHT, showInViewSize.width, TOP_ALERT_VIEW_HEIGHT);
        
        UILabel *label = [self viewWithTag:YZHUIAlertTipsStyleSubViewTagLabelView];
        UIImageView *imageView = [self viewWithTag:YZHUIAlertTipsStyleSubViewTagImageView];
        
        NSText *text = [[NSText alloc] initWithTextObj:self.alertTitle];
        if (IS_AVAILABLE_NSSTRNG(text.text)) {
            label.text = text.text;
            label.font = self.cellHeadTitleTextFont;
            label.textColor = self.cellHeadTitleTextColor;
        }
        else if (text.attributedText)
        {
            label.attributedText = text.attributedText;
        }

        [label sizeToFit];
        
        CGSize size = label.frame.size;
        CGFloat x = (showInViewSize.width - size.width)/2;
        CGFloat diff = STATUS_BAR_HEIGHT;
        CGFloat y = TOP_ALERT_VIEW_HEIGHT - TOP_ALERT_VIEW_MIN_HEIGHT + diff;
        label.frame = CGRectMake(x, y, size.width, TOP_ALERT_VIEW_MIN_HEIGHT - diff);

        CGFloat imageWidth = 20;
        CGFloat imageHeight = 20;
        CGFloat imageX = MAX(0, x - imageWidth - 10);
        CGFloat imageY = TOP_ALERT_VIEW_HEIGHT - TOP_ALERT_VIEW_MIN_HEIGHT + diff + (TOP_ALERT_VIEW_MIN_HEIGHT - diff - imageHeight)/2;
        imageView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight);
        imageView.image = [UIImage imageNamed:self.cellHeadImageName];
        if (self.alertViewStyle == YZHUIAlertViewStyleTopWarningTips) {
            if (IS_AVAILABLE_NSSTRNG(text.text)) {
                label.font = self.cellHeadTitleHighlightTextFont;
                label.textColor = self.cellHeadTitleHighlightTextColor;
            }
            imageView.image = [UIImage imageNamed:self.cellHeadHighlightImageName];
        }
    }
}

-(YZHUIAlertActionBlock)_alertCancelActionBlock
{
    return nil;
}

-(YZHAlertActionModel*)cancelModel
{
    if (_cancelModel == nil) {
        _cancelModel = [[YZHAlertActionModel alloc] init];
        _cancelModel.actionTitleText = NSLOCAL_STRING(@"取消");
        _cancelModel.actionStyle = UIAlertActionStyleDefault;
        _cancelModel.actionBlock = [self _alertCancelActionBlock];
    }
    return _cancelModel;
}

-(NSMutableArray*)actionModels
{
    if (_actionModels == nil) {
        _actionModels = [NSMutableArray array];
    }
    return _actionModels;
}

-(BOOL)_canAddAlertActionWithActionStyle:(YZHUIAlertActionStyle)actionStyle
{
    if (YZHUIALERT_ACTION_STYLE_IS_HEAD(actionStyle)) {
        return NO;
    }
    if (self.alertViewStyle == YZHUIAlertViewStyleAlertInfo) {
        if (actionStyle == YZHUIAlertActionStyleTextEdit) {
            return NO;
        }
    }
    else if (self.alertViewStyle == YZHUIAlertViewStyleAlertEdit) {
        
    }
    else if (self.alertViewStyle == YZHUIAlertViewStyleAlertForce)
    {
        
    }
    else if (self.alertViewStyle == YZHUIAlertViewStyleActionSheet)
    {
        if (!YZHUIALERT_ACTION_STYLE_IS_SHEET_SUPPORT(actionStyle)) {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    return YES;
}

-(YZHAlertActionModel *)addAlertActionWithTitle:(id)actionTitle actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock
{
    return [self addAlertActionWithActionId:nil actionTitle:actionTitle actionStyle:actionStyle actionBlock:actionBlock];
}

-(YZHAlertActionModel *)addAlertActionWithActionId:(NSString *)actionId actionTitle:(id)actionTitle actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock
{
    BOOL canAdd = [self _canAddAlertActionWithActionStyle:actionStyle];
    if (canAdd) {
        YZHAlertActionModel *model = [[YZHAlertActionModel alloc] init];
        model.actionId = actionId;
        model.actionTitleText = actionTitle;
        model.actionStyle = actionStyle;
        model.actionBlock = actionBlock;
        [self.actionModels addObject:model];
        
        return model;
    }
    return nil;
}

-(YZHAlertActionModel *)addAlertActionWithCustomCellBlock:(YZHUIAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHUIAlertActionBlock)actionBlock
{
    BOOL canAdd = [self _canAddAlertActionWithActionStyle:YZHUIAlertActionStyleCustomView];
    if (canAdd) {
        YZHAlertActionModel *model = [[YZHAlertActionModel alloc] init];
        model.actionStyle = YZHUIAlertActionStyleCustomView;
        model.customCellBlock = customCellBlock;
        model.actionBlock = actionBlock;
        [self.actionModels addObject:model];
        return model;
    }
    return nil;
}

-(YZHAlertActionModel *)addAlertActionWithActionModel:(YZHAlertActionModel *)actionModel
{
    BOOL canAdd = NO;
    if (actionModel) {
        canAdd = [self _canAddAlertActionWithActionStyle:actionModel.actionStyle];
        if (canAdd) {
            [self.actionModels addObject:actionModel];
            return actionModel;
        }
    }
    return nil;
}

-(void)addAlertActionWithoutCheckWithTitle:(id)title actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock
{
    YZHAlertActionModel *model = [[YZHAlertActionModel alloc] init];
    model.actionTitleText = title;
    model.actionStyle = actionStyle;
    model.actionBlock = actionBlock;
    [self.actionModels addObject:model];
}

-(CGFloat)_getDefaultAnimateDuration
{
    if (YZHUIALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        return defaultYZHUIAlertViewStyleTopTipsAnimateDuration;
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle))
    {
        return defaultYZHUIAlertViewStyleAlertAnimateDuration;
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        return defaultYZHUIAlertViewStyleActionSheetAnimateDuration;
    }
    return 0;
}

-(void)_showInView:(UIView *)inView frame:(CGRect)frame
{
    [self prepareShowInView:inView];
    
    if (CGSizeEqualToSize(frame.size, CGSizeZero)) {
        frame = self.showInView.bounds;
    }
    
    [self.showInView addSubview:self];
    
    self.cover.frame = frame;
    if (self.cover) {
        [self.showInView insertSubview:self.cover belowSubview:self];
    }
    
    void (^showCompletionBlock)(BOOL finished) = ^(BOOL finished){
        if (self.alertViewStyle == YZHUIAlertViewStyleAlertInfo && self.delayDismissInterval > 0) {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:self.delayDismissInterval];
        }
        [self registerNotification:YES];
        if (self.didShowBlock) {
            self.didShowBlock(self);
        }
    };
    
    if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
        if ([self _haveTransformYAnimated]) {
            CGSize size = self.bounds.size;
            CGFloat translationY = size.height + (self.showInView.bounds.size.height - size.height)/2;
            
            [UIView animateWithDuration:self.animateDuration delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, translationY);
            } completion:showCompletionBlock];
        }
        else
        {
            showCompletionBlock(YES);
        }
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        CGFloat totalHeight = self.bounds.size.height;
        if ([self _haveTransformYAnimated]) {
            [UIView animateWithDuration:self.animateDuration animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, -totalHeight);
            } completion:showCompletionBlock];
        }
        else
        {
            showCompletionBlock(YES);
        }
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle))
    {
        if ([self _haveTransformYAnimated]) {
            [UIView animateWithDuration:self.animateDuration delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, TOP_ALERT_VIEW_MIN_HEIGHT);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:self.animateDuration delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
            }];
        }
    }
}

-(void)alertShowInView:(UIView*)inView
{
    [self _showInView:inView frame:CGRectZero];
}

-(void)_prepareAnimation:(BOOL)animated
{
    if (!animated) {
        self.animateDuration = 0;
    }
    else
    {
        if (self.animateDuration <= 0.01) {
            self.animateDuration = [self _getDefaultAnimateDuration];
        }
    }
}

-(void)alertShowInView:(UIView *)inView animated:(BOOL)animated
{
    [self _prepareAnimation:animated];
    [self alertShowInView:inView];
}

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame
{
    [self _showInView:inView frame:frame];
}

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame animated:(BOOL)animated
{
    [self _prepareAnimation:animated];
    [self _showInView:inView frame:frame];
}

-(void)_dispatchCompletionAction:(BOOL)finished
{
//    NSLog(@"self=%@,showInView=%@,supperView=%@",self,self.showInView,self.showInView.superview);
    if (self.dismissCompletionBlock) {
        self.dismissCompletionBlock(self, finished);
    }
}

-(void)_dismissAction
{
    [self.cover removeFromSuperview];
    self.cover = nil;
    [self.customContentAlertView removeFromSuperview];
    self.customContentAlertView = nil;
    [self _dispatchCompletionAction:YES];
}

-(void)dismiss
{
    [self endEditing:YES];
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        [self removeFromSuperview];
    };
    
    if (YZHUIALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
        if ([self _haveTransformYAnimated]) {
            CGFloat translationY = self.transform.ty;
            translationY += 40;
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, translationY);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.transform = CGAffineTransformIdentity;
                } completion:completionBlock];
            }];
        }
        else
        {
            completionBlock(YES);
        }
    }
    else if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        if ([self _haveTransformYAnimated]) {
            [UIView animateWithDuration:self.animateDuration animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:completionBlock];
        }
        else
        {
            completionBlock(YES);
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
}

-(void)dismissAnimated:(BOOL)animated
{
    if (animated) {
        self.animateDuration = [self _getDefaultAnimateDuration];
    }
    else
    {
        self.animateDuration = 0;
    }
    [self dismiss];
}

-(UIView*)getShowInView
{
    return self.showInView;
}

+(NSArray<YZHUIAlertView*>*)alertViewsForTag:(NSInteger)tag inView:(UIView*)inView
{
    if (inView == nil) {
        inView = [UIApplication sharedApplication].keyWindow;
    }
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in inView.subviews) {
        if (view.tag == tag && [view isKindOfClass:[self class]]) {
            [views addObject:view];
        }
    }
    return [views copy];
}

+(NSInteger)alertViewCountForTag:(NSInteger)tag inView:(UIView*)inView
{
    return [[self class] alertViewsForTag:tag inView:inView].count;
}

-(void)registerNotification:(BOOL)regist
{

#if USE_KEYBOARD_MANAGER

    if (regist) {
        self.keyboardManager = [[NSKeyboardManager alloc] init];
        self.keyboardManager.relatedShiftView = self;
        self.keyboardManager.firstResponderView = self;
        self.keyboardManager.keyboardMinTop = 5;
    }
    else
    {
        self.keyboardManager.relatedShiftView = nil;
        self.keyboardManager.firstResponderView = nil;
        self.keyboardManager = nil;
    }
#else
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
#endif
    
}

#if !USE_KEYBOARD_MANAGER
#pragma mark keyBoard

-(void)keyBoardWillShow:(NSNotification*)notification
{
    NSTimeInterval time = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyBoardFrame = CGRectZero;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyBoardFrame];
    
    CGFloat diffY = keyBoardFrame.origin.y - CGRectGetMaxY(self.frame);
    if (diffY >= 0) {
        return;
    }
    
    CGFloat oldTranslationY = self.transform.ty;
    
    CGFloat ty = oldTranslationY + diffY;
    
    [UIView animateWithDuration:time animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, ty);
    }];
}

-(void)keyBoardWillHide:(NSNotification*)notification
{
    NSTimeInterval time = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGSize size = self.bounds.size;
    CGFloat translationY = size.height + (self.cover.bounds.size.height - size.height)/2;
    
    [UIView animateWithDuration:time animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, translationY);
    }];
}

#endif

-(void)dealloc
{
    NSLog(@"YZHUIAlertView-----------dealloc");
    [self registerNotification:NO];
}

#pragma mark override
-(void)removeFromSuperview
{
    [self _dismissAction];
    [super removeFromSuperview];
}

@end

@implementation YZHUIAlertView (YZHUIAlertViewAttributes)

-(YZHAlertActionModel*)alertActionModelForModelIndex:(NSInteger)index
{
    if (index < 0 || index >= self.actionModels.count) {
        return nil;
    }
    YZHAlertActionModel *actionModel = self.actionModels[index];
    return actionModel;
}

-(UIView*)prepareShowInView:(UIView*)inView
{
    if (YZHUIALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        [self.actionModels addObject:self.cancelModel];
    }
    UIView *showInView = inView;
    if (!showInView) {
        showInView = [UIApplication sharedApplication].keyWindow;
    }
    [self _createAlertActionCellWithShowInView:showInView];
    return self.showInView;
}

-(YZHUIAlertActionCell*)_alterActionCellForActionModel:(YZHAlertActionModel*)actionModel cellIndex:(NSInteger)cellIndex
{
    __block YZHUIAlertActionCell *cell = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (NSOBJ_TYPE_IS_CLASS(obj, YZHUIAlertActionCell)) {
            YZHUIAlertActionCell *cellTmp = (YZHUIAlertActionCell*)obj;
            if ((actionModel != nil && cellTmp.actionModel == actionModel) || (actionModel.actionId != nil && [cellTmp.actionModel.actionId isEqualToString:actionModel.actionId]) || (cellIndex >= 0 && cellTmp.cellIndex == cellIndex)) {
                cell = cellTmp;
                *stop = YES;
            }
        }
    }];
    return cell;
}

-(UILabel*)alertTextLabelForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:actionModel cellIndex:-1];
    return cell.textLabel;
}

-(UITextField*)alertEditTextFieldForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:actionModel cellIndex:-1];
    return cell.editTextField;
}

-(UIView*)alertCustomCellSubViewForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:actionModel cellIndex:-1];
    return cell.customView;
}

-(UIView*)alertCellContentViewForAlertActionModelIndex:(NSInteger)index
{
    if (index < 0 || index >= self.actionModels.count) {
        return nil;
    }
    YZHAlertActionModel *actionModel = self.actionModels[index];
    
    YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:actionModel cellIndex:index];
    if (cell.cellType == NSAlertActionCellTypeTextLabel) {
        return cell.textLabel;
    }
    else if (cell.cellType == NSAlertActionCellTypeTextField)
    {
        return cell.editTextField;
    }
    else if (cell.cellType == NSAlertActionCellTypeCustomView)
    {
        return cell.customView;
    }
    return cell.textLabel;
}

-(NSDictionary*)getAllAlertEditViewActionModelInfo
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:obj cellIndex:idx];
        if (cell.cellType == NSAlertActionCellTypeTextField) {
            YZHUIAlertActionTextStyle textStyle = obj.textStyle;
            if (textStyle == YZHUIAlertActionTextStyleNormal) {
                obj.alertEditText = cell.editTextField.text;
            }
            else if (textStyle == YZHUIAlertActionTextStyleAttribute)
            {
                obj.alertEditText = cell.editTextField.attributedText;
            }
            [mutDict setObject:obj forKey:@(cell.cellIndex)];
        }
    }];
    return [mutDict copy];
}

-(NSDictionary*)getAllAlertCustomCellViewInfo
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:obj cellIndex:idx];
        if (cell.cellType == NSAlertActionCellTypeCustomView)
        {
            [mutDict setObject:cell.customView forKey:@(cell.cellIndex)];
        }
    }];
    return [mutDict copy];
}

-(NSDictionary*)getAllAlertActionCellInfo
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YZHUIAlertActionCell *cell = [self _alterActionCellForActionModel:obj cellIndex:idx];
        if (cell.cellType == NSAlertActionCellTypeCustomView)
        {
            [mutDict setObject:cell.customView forKey:@(cell.cellIndex)];
        }
        else if (cell.cellType == NSAlertActionCellTypeTextField)
        {
            YZHUIAlertActionTextStyle textStyle = obj.textStyle;
            if (textStyle == YZHUIAlertActionTextStyleNormal) {
                obj.alertEditText = cell.editTextField.text;
            }
            else if (textStyle == YZHUIAlertActionTextStyleAttribute)
            {
                obj.alertEditText = cell.editTextField.attributedText;
            }
            [mutDict setObject:obj forKey:@(cell.cellIndex)];
        }
    }];
    return [mutDict copy];
}
@end
