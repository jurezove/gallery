//
//  LoadingCollectionViewCell.m
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import "LoadingCollectionViewCell.h"

@interface LoadingCollectionViewCell()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadingCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }
    return self;
}

@end
