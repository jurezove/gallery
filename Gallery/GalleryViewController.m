//
//  GalleryViewController.m
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import "GalleryViewController.h"
#import "Photo.h"
#import "PhotoFetcher.h"
#import "PhotoCollectionViewCell.h"
#import "LoadingCollectionViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface GalleryViewController ()

@property NSArray *photos;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoading;

@end

@implementation GalleryViewController

static NSString *PhotoCollectionViewCellIdentifier =    @"PhotoCollectionViewCell";
static NSString *LoadingCollectionViewCellIdentifier =  @"LoadingCollectionViewCell";

#pragma Lazy loading properties

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:PhotoCollectionViewCellIdentifier];
        [_collectionView registerClass:[LoadingCollectionViewCell class] forCellWithReuseIdentifier:LoadingCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

#pragma mark - Standard view stuff

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gallery";
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.refreshControl];
    [self reload];
}

#pragma mark - Image Fetching

- (void)reload {
    self.page = 1;
    [self fetchBirthdayImages];
}

- (void)finishedFetchingPhotos {
    [self.refreshControl endRefreshing];
    [self.collectionView reloadData];
    self.isLoading = NO;
}

- (void)fetchBirthdayImages {
    self.isLoading = YES;
    NSLog(@"Fetching page: %ld", (long)self.page);
    [[PhotoFetcher sharedFetcher] fetchFlickrImagesWithTags:@[@"birthday"]
                                                    andPage:self.page
                                                    success:^(NSArray *photos) {
                                                        if (self.page == 1)
                                                            self.photos = photos;
                                                        else
                                                            self.photos = [self.photos arrayByAddingObjectsFromArray:photos];
                                                        
                                                        [self finishedFetchingPhotos];
                                                    } error:^(NSURLSessionDataTask *task, NSError *error) {
                                                        NSLog(@"Error: %@\n With url: %@", error, task.response.URL);
                                                        [self finishedFetchingPhotos];
                                                    }];
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.photos.count) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:LoadingCollectionViewCellIdentifier forIndexPath:indexPath];
    } else {
        PhotoCollectionViewCell *collectionViewCell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:PhotoCollectionViewCellIdentifier                                                                                         forIndexPath:indexPath];

        Photo *photo = self.photos[indexPath.row];
        [collectionViewCell.imageView setImageWithURL:[NSURL URLWithString:photo.url] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        
        return collectionViewCell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.photos.count && !self.isLoading && self.photos.count > 0) {
        // Download new page of images
        self.page += 1;
        [self fetchBirthdayImages];
    }
}

@end
