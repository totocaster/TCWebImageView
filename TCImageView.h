//
//  TCImageView.h
//  TCImageViewDemo
//
//  Created by Toto Tvalavadze on 2/17/11.
//  Copyright 2011 63BITS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY 1.0
#define CACHED_IMAGE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface TCImageView : UIImageView {
    
    // Default
    NSURL* url;
    UIImage* placeholderImage;
    
    // Networking
    NSURLConnection *connection;
    NSMutableData *data;

    // Caching
    BOOL caching;
    NSTimeInterval cacheTime;
    
}
@property (readonly) NSURL* url;
@property (readonly) UIImage* placeholderImage;
@property (assign,readwrite,getter = isCaching) BOOL caching;
@property (assign,readwrite) NSTimeInterval cacheTime;


- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image;

- (void)loadImage;

- (void)resetCache;


@end
