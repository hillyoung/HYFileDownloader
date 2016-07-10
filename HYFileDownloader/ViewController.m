//
//  ViewController.m
//  HYFileDownloader
//
//  Created by yanghaha on 16/7/10.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "ViewController.h"
#import "HYFileDownloader.h"
#import "DownloadProgressCell.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadProgressCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDownloadTaskFinished:) name:HYFileDownloadTaskDidFinished object:nil];


    [[HYFileDownloader defaultDownloader] loadAllItems];

//    HYFileDownloadTask *task = [[HYFileDownloadTask alloc] initWithTitle:@"20121214224850_MdY4C.jpeg" ulrstr:@"http://cdn.duitang.com/uploads/item/201212/14/20121214224850_MdY4C.jpeg" filePath:@"20121214224850_MdY4C.jpeg" contentLength:0];
    HYFileDownloadTask *task = [[HYFileDownloadTask alloc] initWithTitle:@"20121214224850_MdY4C" ulrstr:@"http://vliveachy.tc.qq.com/music.qqvideo.tc.qq.com/m00171zs4ji.p1302.1.mp4?vkey=B37EB83D38FF4AFBE816E6CDE01834AEE08D33BD8331BDF447BCA7529E9D200B754C1BAD72F8FBE9E0099F532320D3B8B148284A975E72787C6D9F2959CCB0596DAB2129426D8716C74F71EC9D183C7B48ACF683476C1082&ocid=250224556&ocid=542053804" filePath:@"20121214224850_MdY4C" contentLength:0];


    [[HYFileDownloader defaultDownloader] addTask:task];


//    task = [[HYFileDownloadTask alloc] initWithTitle:@"dbb44aed2e738bd4fb034eb5a18b87d6277ff910" ulrstr:@"http://imgsrc.baidu.com/forum/pic/item/dbb44aed2e738bd4fb034eb5a18b87d6277ff910.jpg" filePath:@"dbb44aed2e738bd4fb034eb5a18b87d6277ff910" contentLength:0];
    task = [[HYFileDownloadTask alloc] initWithTitle:@"dbb44aed2e738bd4fb034eb5a18b87d6277ff910" ulrstr:@"http://14.29.86.12/vhot2.qqvideo.tc.qq.com/o0127osqybm.p701.1.mp4?vkey=7E458F16BD0257F77ACF7FFE1AEEACA21BC253BD6C19B15A921EEF837496349CE6F2B420A75C98B4D68851FDF5617EF7EB1D127A3146AFD84719911A85F670A259E3C245E009A610DE59DFC9A59BD8EBC489F8182228E4C8&locid=4397bc7e-a5c1-4624-9a90-cf6a6026837d&size=20676231&ocid=267001772" filePath:@"dbb44aed2e738bd4fb034eb5a18b87d6277ff910" contentLength:0];


    [[HYFileDownloader defaultDownloader] addTask:task];

    task = [[HYFileDownloadTask alloc] initWithTitle:@"b0020op7h63" ulrstr:@"http://14.29.86.12/music.qqvideo.tc.qq.com/b0020op7h63.p301.1.mp4?vkey=B39DE18C68A4079A53A3202BFE069EB45F9F7AC49C309F407609235BBE0296AC55FB2DD97D61E0218F06ECF238B97908E1938C65649CF8179B8C4D3A44B7480C401FAB41900826736A4B05B958C5435CA2C6B163069E9F21&locid=7703bb82-a704-4f37-b177-020d7c456e51&size=31705757&ocid=300556204" filePath:@"b0020op7h63" contentLength:0];


    [[HYFileDownloader defaultDownloader] addTask:task];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveDownloadTaskFinished:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 1) {
        return [HYFileDownloader defaultDownloader].downloadedTasks.count;
    }

    return [HYFileDownloader defaultDownloader].downloadingTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DownloadProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    HYFileDownloadTask *task = nil;

    if (indexPath.section == 1) {
        task = [HYFileDownloader defaultDownloader].downloadedTasks[indexPath.row];
    } else {
        task = [HYFileDownloader defaultDownloader].downloadingTasks[indexPath.row];
    }


    [cell setHandleBlock:^(DownloadProgressCell *cell) {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        HYFileDownloadTask *task = [HYFileDownloader defaultDownloader].downloadingTasks[indexPath.row];

        if (task.task.state != NSURLSessionTaskStateRunning) {
            [task resume];
        } else {
            [task suspend];
        }
    }];

    typeof(&*self) weakSelf = self;
    [task setProgressBlock:^(HYFileDownloadTask *task, double progress) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[HYFileDownloader defaultDownloader].downloadingTasks indexOfObject:task] inSection:0];
        [[weakSelf.tableView cellForRowAtIndexPath:indexPath] updateWithTitle:nil progress:progress];
    }];

    [cell updateWithTitle:nil progress:indexPath.section];

    cell.titleLabel.text = task.title;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section==1? @"已下载":@"下载中";
}

@end
