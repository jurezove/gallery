//
//  PhotoFetcher.m
//  Gallery
//
//  Created by Jure Žove on 5. 10. 14.
//  Copyright (c) 2014 Jure Zove. All rights reserved.
//

#import "PhotoFetcher.h"
#import "FlickrAPI.h"
#import "FlickrPhoto.h"

@implementation PhotoFetcher

+ (PhotoFetcher *)sharedFetcher {
    static PhotoFetcher *_sharedFetcher = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFetcher = [[self alloc] init];
    });
    
    return _sharedFetcher;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)fetchFlickrImagesWithTags:(NSArray *)tags andPage:(NSInteger)page success:(PhotoFetcherSuccessBlock)successBlock error:(PhotoFetcherErrorBlock)errorBlock {
    [self GET:[FlickrAPI urlForSearch] parameters:[FlickrAPI paramsForSearchByTags:tags andPage:page] success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock([FlickrPhoto photoArrayWithResponseDictionary:responseObject]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorBlock(task, error);
    }];
}

@end