//
//  DownloadProgressCell.m
//  progress
//
//  Created by yanghaha on 16/4/28.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "DownloadProgressCell.h"

@interface DownloadProgressCell ()

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation DownloadProgressCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


- (IBAction)touchHandleButton:(UIButton *)sender {
    if (self.handleBlock) {
        self.handleBlock(self);
    }
}

- (void)updateLabelText:(CGFloat)progress {
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", progress*100];
}

#pragma mark - Message

- (void)updateHandleButtonStauts:(BOOL)canStart {
    self.startButton.selected = !canStart;
}

- (void)updateProgress:(CGFloat)progress {
    [self updateLabelText:progress];
    self.progressView.progress = progress;
}

//- (void)setModel:(HYFileDownloadItem *)model {
//    self.titleLabel.text = model.title;
//
//    float progress = 1.*model.currentLength/model.contentLength;
//
//    [self updateProgress:progress>0&&progress<1? progress:0];
//}

- (void)updateWithTitle:(NSString *)title progress:(CGFloat)progress {
//    self.titleLabel.text = title;

    [self updateProgress:progress];
}

@end
