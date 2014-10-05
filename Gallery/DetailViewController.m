//
//  DetailViewController.m
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoCollectionViewCell.h"

@interface DetailViewController ()

//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString *PhotoCollectionViewCellIdentifier = @"PhotoCollectionViewCell";

@implementation DetailViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setMinimumInteritemSpacing:0.0f];
        [flowLayout setMinimumLineSpacing:0.0f];
        flowLayout.itemSize = self.view.frame.size;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor blackColor];
        [_collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:PhotoCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // I'm using the Photo object instead of passing the UIImage because the detail view controller could be called before the image is downloaded in the gallery view controller.
    // Because AFNetworking is caching images, it will not be downloaded again here.
    Photo *selectedPhoto = self.photos[self.selectedPhotoIndex];
    self.title = selectedPhoto.title;
    [self.view addSubview:self.collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedPhotoIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *collectionViewCell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:PhotoCollectionViewCellIdentifier                                                                                         forIndexPath:indexPath];
    
    Photo *photo = self.photos[indexPath.row];
    [collectionViewCell.imageView setImageWithURL:[NSURL URLWithString:photo.url] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    collectionViewCell.isScallable = YES;
    
    return collectionViewCell;
}

@end
