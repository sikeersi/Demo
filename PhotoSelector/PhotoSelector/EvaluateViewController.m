//
//  EvaluateViewController.m
//  PhotoSelector
//
//  Created by 洪雯 on 2017/1/12.
//  Copyright © 2017年 洪雯. All rights reserved.
//

#import "EvaluateViewController.h"
#import "BRPlaceholderTextView.h"
#import "UIView+WLFrame.h"
#define iphone4 (CGSizeEqualToSize(CGSizeMake(320, 480), [UIScreen mainScreen].bounds.size))
#define iphone5 (CGSizeEqualToSize(CGSizeMake(320, 568), [UIScreen mainScreen].bounds.size))
#define iphone6 (CGSizeEqualToSize(CGSizeMake(375, 667), [UIScreen mainScreen].bounds.size))
#define iphone6plus (CGSizeEqualToSize(CGSizeMake(414, 736), [UIScreen mainScreen].bounds.size))
//默认最大输入字数为  kMaxTextCount  300
#define kMaxTextCount 300
#define HeightVC [UIScreen mainScreen].bounds.size.height//获取设备高度
#define WidthVC [UIScreen mainScreen].bounds.size.width//获取设备宽度

@interface EvaluateViewController ()<UIScrollViewDelegate,UITextViewDelegate>
{
    float _TimeNUMX;
    float _TimeNUMY;
    int _FontSIZE;
    float allViewHeight;
    //备注文本View高度
    float noteTextHeight;
}

/**
 *  主视图-
 */
@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong)UIView *addView;

@property (nonatomic, strong) BRPlaceholderTextView *noteTextView;

@property (nonatomic,strong) UIButton * sureBtn;

@property (nonatomic,strong) NSMutableArray * photoArr;

@property (nonatomic,copy)   NSString * photoStr;

@property (nonatomic,copy)   NSString * modelUrl;

@end

@implementation EvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"评价";
    //收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    
    _TimeNUMX = [self BackTimeNUMX];
    _TimeNUMY = [self BackTimeNUMY];
    
    [self createUI];
}
#pragma mark - lazyLoading
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WidthVC, HeightVC)];
        _mainScrollView.contentSize =CGSizeMake(WidthVC, HeightVC);
        _mainScrollView.bounces =YES;
        _mainScrollView.showsVerticalScrollIndicator = false;
        _mainScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.view addSubview:_mainScrollView];
        [_mainScrollView setDelegate:self];
        self.showInView = _mainScrollView;
    }
    return _mainScrollView;
}

-(UIView *)addView{
    if (!_addView) {
        _addView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WidthVC, 80)];
        _addView.backgroundColor = [UIColor redColor];
        [self.mainScrollView addSubview:_addView];
    }
    return _addView;
}

-(BRPlaceholderTextView *)noteTextView{
    if (!_noteTextView) {
        _noteTextView = [[BRPlaceholderTextView alloc]init];
        _noteTextView.keyboardType = UIKeyboardTypeDefault;
        //文字样式
        [_noteTextView setFont:[UIFont fontWithName:@"Heiti SC" size:15.5]];
        _noteTextView.maxTextLength = kMaxTextCount;
        [_noteTextView setTextColor:[UIColor blackColor]];
        _noteTextView.delegate = self;
        _noteTextView.font = [UIFont boldSystemFontOfSize:15.5];
        _noteTextView.placeholder= @"    请输入任务描述...";
        _noteTextView.returnKeyType = UIReturnKeyDone;
        [_noteTextView setPlaceholderColor:[UIColor lightGrayColor]];
        [_noteTextView setPlaceholderOpacity:1];
        _noteTextView.textContainerInset = UIEdgeInsetsMake(5, 15, 5, 15);
        _noteTextView.frame = CGRectMake(20, self.addView.bottom + 20, WidthVC - 40, 60);
        [self.mainScrollView addSubview:_noteTextView];
    }
    return _noteTextView;
}

-(UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.pickerCollectionView.bottom + 20, WidthVC - 40, 30)];
        _sureBtn.backgroundColor = [UIColor orangeColor];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:17.0+_FontSIZE];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _sureBtn.layer.masksToBounds = YES;
        _sureBtn.layer.cornerRadius = 5.0;
        [_sureBtn addTarget:self action:@selector(ClickSureBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:_sureBtn];
    }
    return _sureBtn;
}

/**
 *  取消输入
 */
- (void)viewTapped{
    [self.view endEditing:YES];
}

- (void)createUI{
    
    self.mainScrollView.hidden = false;

    /** 初始化collectionView */
    [self initPickerView];
    self.addView.hidden = false;
    self.noteTextView.hidden = false;
    self.sureBtn.hidden = false;
    
    [self updateViewsFrame];
}

/**
 *  界面布局 frame
 */
- (void)updateViewsFrame{
    
    if (!allViewHeight) {
        allViewHeight = 0;
    }
    if (!noteTextHeight) {
        noteTextHeight = 150*_TimeNUMY;
    }
    

    
    //文本编辑框
//    _noteTextView.frame = CGRectMake(0, _noteTextBackgroudView.frame.origin.y+_noteTextBackgroudView.frame.size.height+10*_TimeNUMY, WidthVC, noteTextHeight);
    


    
    //photoPicker
    [self updatePickerViewFrameY:self.noteTextView.bottom + 20];
    
    self.sureBtn.frame = CGRectMake(20, self.pickerCollectionView.bottom + 20, WidthVC - 40, 30);
    
    allViewHeight = self.sureBtn.frame.origin.y+self.sureBtn.frame.size.height+10*_TimeNUMY;
    
    _mainScrollView.contentSize = self.mainScrollView.contentSize = CGSizeMake(0,allViewHeight);
}


- (void)pickerViewFrameChanged{
    [self updateViewsFrame];
}

#pragma mark - UITextViewDelegate

/**
 *  文本高度自适应
 */
-(void)textChanged{
    
    CGRect orgRect = self.noteTextView.frame;//获取原始UITextView的frame
    
    //获取尺寸
    CGSize size = [self.noteTextView sizeThatFits:CGSizeMake(self.noteTextView.frame.size.width, MAXFLOAT)];
    
    orgRect.size.height=size.height+10;//获取自适应文本内容高度
    
    
    //如果文本框没字了恢复初始尺寸
    if (orgRect.size.height > 100) {
        noteTextHeight = orgRect.size.height;
    }else{
        noteTextHeight = 100;
    }
    
    [self updateViewsFrame];
}

#pragma mark - UIScrollViewDelegate
//用户向上偏移到顶端取消输入,增强用户体验
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        [self.view endEditing:YES];
    }
}
#pragma mark 确定评价的方法
- (void)ClickSureBtn:(UIButton *)sender{
    if (self.noteTextView.text.length == 0 ) {
        NSLog(@"您的评价描述字数不够哦!");
        return;
    }
    if (self.noteTextView.text.length > kMaxTextCount) {
        NSLog(@"您的评价描述字数太多了哦!");
        return;
    }
    
    self.photoArr = [[NSMutableArray alloc] initWithArray:[self getBigImageArray]];
    
    if (self.photoArr.count >5){
        NSLog(@"最多上传5张照片!");
        
    }else if (self.photoArr.count == 0){
        NSLog(@"请上传照片!");
        
    }else{
        /** 上传的接口方法 */
    }
}
#pragma mark 返回不同型号的机器的倍数值
- (float)BackTimeNUMX {
    float numX = 0.0;
    if (iphone4) {
        numX = 320 / 375.0;
        return numX;
    }
    if (iphone5) {
        numX = 320 / 375.0;
        return numX;
    }
    if (iphone6) {
        return 1.0;
    }
    if (iphone6plus) {
        numX = 414 / 375.0;
        return numX;
    }
    return numX;
}
- (float)BackTimeNUMY {
    float numY = 0.0;
    if (iphone4) {
        numY = 480 / 667.0;
        _FontSIZE = -2;
        return numY;
    }
    if (iphone5) {
        numY = 568 / 667.0;
        _FontSIZE = -2;
        return numY;
    }
    if (iphone6) {
        _FontSIZE = 0;
        return 1.0;
    }
    if (iphone6plus) {
        numY = 736 / 667.0;
        _FontSIZE = 2;
        return numY;
    }
    return numY;
}


@end
