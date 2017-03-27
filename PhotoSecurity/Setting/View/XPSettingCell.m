//
//  XPSettingCell.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/21.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPSettingCell.h"

@implementation XPSettingCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.stateSwitch setHidden:YES];
    self.accessoryType = UITableViewCellAccessoryNone;
}

@end
