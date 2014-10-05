//
//  PhotoFetcher.h
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^PhotoFetcherSuccessBlock)(NSArray *photos);
typedef void (^PhotoFetcherErrorBlock)(NSURLSessionDataTask *task, NSError *error);

@interface PhotoFetcher : AFHTTPSessionManager

+ (PhotoFetcher *)sharedFetcher;

- (void)fetchFlickrImagesWithTags:(NSArray *)tags andPage:(NSInteger)page success:(PhotoFetcherSuccessBlock)successBlock error:(PhotoFetcherErrorBlock)errorBlock;
- (void)fetchFlickrImagesWithTags:(NSArray *)tags withCoordinate:(CLLocationCoordinate2D)coordinate andPage:(NSInteger)page success:(PhotoFetcherSuccessBlock)successBlock error:(PhotoFetcherErrorBlock)errorBlock;

@end
