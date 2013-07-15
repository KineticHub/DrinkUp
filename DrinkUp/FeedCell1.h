//
//  FeedCell1.h
//  ADVFlatUI
//
//  Created by Tope on 03/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell1 : UITableViewCell

@property (nonatomic, strong) UIImageView* picImageView;

@property (nonatomic, strong) UIView* feedContainer;

@property (nonatomic, strong) UILabel* nameLabel;

@property (nonatomic, strong) UILabel* updateLabel;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, strong) UILabel* commentCountLabel;

@property (nonatomic, strong) UILabel* likeCountLabel;

@property (nonatomic, strong) UIImageView* commentIconImageView;

@property (nonatomic, strong) UIImageView* likeIconImageView;

@end
