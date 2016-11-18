//
//  ViewController.m
//  YMCountdownDemo
//
//  Created by jike on 16/9/7.
//  Copyright © 2016年 YM. All rights reserved.
//

#import "ViewController.h"

#import "YMCountDownCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

// 假数据
@property (nonatomic, strong)NSMutableArray *dataArray;

// countDownTimer
@property (nonatomic, strong)NSTimer *MainTimer;

// 倒计时后新数据保存
@property (nonatomic, strong)NSMutableArray *countDownDataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self setupNav];
    [self initCountDown];
}

- (void)setupTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
}

- (void)setupNav
{
    self.title = @"CountDownDemo";
}

#pragma mark - - 倒计时Timer..
- (void)initCountDown {
    for (NSInteger i = 0; i < self.dataArray.count; i++)
    {
        //将倒计时总秒数数组根据indexpath依次存入字典
        NSDictionary *CountDic = @{@"indexPath":[NSString stringWithFormat:@"%ld",i],@"lastTime": self.dataArray[i]};
        [self.countDownDataArray addObject:CountDic];
    }
    
    // 防止刷新UI的时候创建多个定时器，导致多个定时器一起倒计时。
    if (!self.MainTimer) {
        [self startTimer];
    }
}

//倒计时
- (void)startTimer
{
    self.MainTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLessTime) userInfo:@"" repeats:YES];
    
    //如果不添加下面这条语句，在UITableView拖动的时候，会阻塞定时器的调用
    [[NSRunLoop currentRunLoop] addTimer:self.MainTimer forMode:UITrackingRunLoopMode];
}

//刷新时间
- (void)refreshLessTime
{
    NSUInteger time;
    for (int i = 0; i < self.countDownDataArray.count; i++) {
        time = [[[self.countDownDataArray objectAtIndex:i] objectForKey:@"lastTime"] integerValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[[self.countDownDataArray objectAtIndex:i] objectForKey:@"indexPath"] integerValue] inSection:0];
        NSInteger oldTime;
        if (time == 0) {
            oldTime = 0;
        }else {
            oldTime = --time;
        }
        NSString *str;
        str = [NSString stringWithFormat:@"%@",[self lessSecondToDay:oldTime]];
        
        //根据indexpath取cell
        YMCountDownCell *cell = (YMCountDownCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.countDownLabel.text = [self lessSecondToDay:oldTime];
        
        //将倒计时后的秒数存入数组，刷新数据源。
        NSDictionary *dic = @{@"indexPath": [NSString stringWithFormat:@"%ld",indexPath.row],@"lastTime": [NSString stringWithFormat:@"%ld",time]};
        [self.countDownDataArray replaceObjectAtIndex:i withObject:dic];
    }
}

//根据秒数计算剩余时间：天，小时，分钟，秒
- (NSString *)lessSecondToDay:(NSUInteger)seconds
{
    NSUInteger day  = (NSUInteger)seconds/(24*3600);
    NSUInteger hour = (NSUInteger)(seconds%(24*3600))/3600;
    NSUInteger min  = (NSUInteger)(seconds%(3600))/60;
    NSUInteger second = (NSUInteger)(seconds%60);
    NSString *timeStr;
    if (seconds == 0) {
        timeStr = @"已结束";
        [self countDownFinished];
    }else {
        timeStr = [NSString stringWithFormat:@"%02zd天 %02zd:%02zd:%02zd",(unsigned long)day,(unsigned long)hour,(unsigned long)min,(unsigned long)second];
    }
    return timeStr;
}

// do something when the The countdown ends
- (void)countDownFinished
{
    
}

#pragma mark -- tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identOne = @"countdowncell";
    
    YMCountDownCell * cell = [tableView dequeueReusableCellWithIdentifier:identOne];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"YMCountDownCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 倒计时开始会有一秒的刷新空档期，可以铺上倒计时数据防止界面一片白.(如果有刷新，刷新的时候要更新数据源 self.dataArray)
    NSInteger backTime = [self.dataArray[indexPath.row] integerValue];
    NSString *backStr  = [self lessSecondToDay:backTime];
    cell.countDownLabel.text = backStr;
    
    return cell;
}

#pragma mark - lazy load
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height  - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [@[@"600",@"12345",@"123456",@"234567",@"3456789999"]mutableCopy];
    }
    return _dataArray;
}

-(NSMutableArray *)countDownDataArray
{
    if (!_countDownDataArray) {
        _countDownDataArray = [NSMutableArray array];
    }
    return _countDownDataArray;
}

@end
