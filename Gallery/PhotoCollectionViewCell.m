//
//  PhotoCollectionViewCell.m
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell()

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation PhotoCollectionViewCell

- (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchImage:)];
        _pinchGestureRecognizer.delegate = self;
    }
    return _pinchGestureRecognizer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setIsScallable:(BOOL)isScallable {
    _isScallable = isScallable;
    
    if (_isScallable) {
        if (![self.imageView.gestureRecognizers containsObject:self.pinchGestureRecognizer]) {
            [self.imageView addGestureRecognizer:self.pinchGestureRecognizer];
        }
        self.imageView.userInteractionEnabled = YES;
    } else {
        self.pinchGestureRecognizer = nil;
    }
}

#pragma mark - Scaling image

- (void)scaleImageBack {
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         self.imageView.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

- (void)pinchImage:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.pinchGestureRecognizer) {
        if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
            CGFloat scale = self.pinchGestureRecognizer.scale;
            self.imageView.transform = CGAffineTransformScale(self.imageView.transform, scale, scale);
            self.pinchGestureRecognizer.scale = 1.0;
        } else {
            [self scaleImageBack];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
