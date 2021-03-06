//
//  GalleryViewController.m
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import "GalleryViewController.h"
#import "FlickrData.h"
#import "PhotoFetcher.h"

#import "PhotoCollectionViewCell.h"
#import "LoadingCollectionViewCell.h"
#import "EmptyCollectionViewCell.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "DetailViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface GalleryViewController ()

@property FlickrData *flickrData;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL nearbyPhotos;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;

@end

@implementation GalleryViewController

static NSString *PhotoCollectionViewCellIdentifier =    @"PhotoCollectionViewCell";
static NSString *LoadingCollectionViewCellIdentifier =  @"LoadingCollectionViewCell";
static NSString *EmptyCollectionViewCellIdentifier =    @"EmptyCollectionViewCell";

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
        [_collectionView registerClass:[EmptyCollectionViewCell class] forCellWithReuseIdentifier:EmptyCollectionViewCellIdentifier];
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

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    return _locationManager;
}

#pragma mark - Standard view stuff

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateToNearby:NO];
    [self setupLocationButton];
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)setupLocationButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Location"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toggleNearbyPhotos)];
}

#pragma mark - Image Fetching

- (void)reload {
    self.page = 1;
    [self fetchBirthdayPhotos];
}

- (void)finishedFetchingPhotos {
    [self.refreshControl endRefreshing];
    [self.collectionView reloadData];
    self.isLoading = NO;
}

- (void)displayErrorAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"An error occurred. :-( Please try again later."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)fetchBirthdayPhotos {
    self.isLoading = YES;
    if (self.nearbyPhotos && CLLocationCoordinate2DIsValid(self.lastCoordinate)) {
        [[PhotoFetcher sharedFetcher] fetchFlickrImagesWithTags:@[@"birthday"]
                                                 withCoordinate:self.lastCoordinate
                                                        andPage:self.page
                                                        success:^(FlickrData *newData) {
                                                            if (self.page == 1)
                                                                self.flickrData = newData;
                                                            else
                                                                [self.flickrData appendPhotos:newData.photos];
                                                            
                                                            [self finishedFetchingPhotos];
                                                        } error:^(NSURLSessionDataTask *task, NSError *error) {
                                                            NSLog(@"Error: %@\n With url: %@", error, task.response.URL);
                                                            [self displayErrorAlert];
                                                            [self finishedFetchingPhotos];
                                                        }];
    } else {
        [[PhotoFetcher sharedFetcher] fetchFlickrImagesWithTags:@[@"birthday"]
                                                        andPage:self.page
                                                        success:^(FlickrData *newData) {
                                                            if (self.page == 1)
                                                                self.flickrData = newData;
                                                            else
                                                                [self.flickrData appendPhotos:newData.photos];
                                                            
                                                            [self finishedFetchingPhotos];
                                                        } error:^(NSURLSessionDataTask *task, NSError *error) {
                                                            NSLog(@"Error: %@\n With url: %@", error, task.response.URL);
                                                            [self displayErrorAlert];
                                                            [self finishedFetchingPhotos];
                                                        }];
    }
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.flickrData.photos.count + 1, self.flickrData.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.flickrData.count && !self.isLoading && indexPath.row == 0) {
        // No results, empty cell
        return [collectionView dequeueReusableCellWithReuseIdentifier:EmptyCollectionViewCellIdentifier forIndexPath:indexPath];
    } else if (indexPath.row >= self.flickrData.photos.count) {
        // Loading cell
        if (!self.isLoading && self.flickrData.photos.count > 0) {
            // Download new page of photos
            self.page += 1;
            [self fetchBirthdayPhotos];
        }
        return [collectionView dequeueReusableCellWithReuseIdentifier:LoadingCollectionViewCellIdentifier forIndexPath:indexPath];
    } else {
        // Photo cell
        PhotoCollectionViewCell *collectionViewCell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:PhotoCollectionViewCellIdentifier                                                                                         forIndexPath:indexPath];

        Photo *photo = self.flickrData.photos[indexPath.row];
        [collectionViewCell.imageView setImageWithURL:[NSURL URLWithString:photo.url] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        
        return collectionViewCell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.photos = self.flickrData.photos;
    detailViewController.selectedPhotoIndex = indexPath.row;
    [self.navigationController pushViewController:detailViewController animated:YES];    
}

#pragma mark - Nearby Photos

- (void)toggleNearbyPhotos {
    [self updateToNearby:!self.nearbyPhotos];
}

- (void)updateToNearby:(BOOL)nearby {
    self.nearbyPhotos = nearby;
    if (self.nearbyPhotos) {
        [self tryGettingCurrentLocation];
        self.title = @"Nearby Birthday Photos";
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"Cross"];
    } else {
        self.title = @"Birthday Photos";
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"Location"];
        [self emptyCollectionView];
        [self reload];
    }
}

- (void)emptyCollectionView {
    self.flickrData.photos = @[];
    [self.collectionView reloadData];
}

#pragma mark - Location

- (void)initiateLocationFetch {
    [self emptyCollectionView];
    [self.locationManager startUpdatingLocation];
}

- (void)tryGettingCurrentLocation {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
        [self.locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled])
        [self initiateLocationFetch];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
        [self initiateLocationFetch];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Get first location and use it with the Flickr API
    CLLocation *location = [locations firstObject];
    self.lastCoordinate = location.coordinate;
    [manager stopUpdatingLocation];
    [self reload];
}

@end
