//
//  DownloadProgressCell.h
//  progress
//
//  Created by yanghaha on 16/4/28.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Identifer_DownloadProgressCell @"DownloadProgressCell"

@interface DownloadProgressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (copy, nonatomic) void(^handleBlock)(DownloadProgressCell *cell);

/**
 *  设置按钮点击，开始或暂停
 *
 *  @param canStart 是否显示开始
 */
- (void)updateHandleButtonStauts:(BOOL)canStart ;

- (void)updateProgress:(CGFloat)progress ;

//- (void)setModel:(HYFileDownloadItem *)model;

- (void)updateWithTitle:(NSString *)title progress:(CGFloat)progress ;

@end
