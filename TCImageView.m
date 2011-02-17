//
//  TCImageView.m
//  TCImageViewDemo
//
//  Created by Toto Tvalavadze on 2/17/11.
//  Copyright 2011 63BITS. All rights reserved.
//

#import "TCImageView.h"


@implementation TCImageView

@synthesize caching, url, placeholderImage, cacheTime;

- (id)initWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)image;
{    
    // Default Inits
    placeholderImage = [image retain];
    url = [imageURL retain];
    self.caching = NO;
    self.cacheTime = (double)604800; // 7 days
    
    return [self initWithImage:self.placeholderImage];
}

- (void)loadImage
{
    if (!self.caching){
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    } else {
        
    }
}

#pragma -
#pragma NSURLConnection Delegates

- (void)connection:(NSURLConnection *)theConnection  didReceiveData:(NSData *)incrementalData 
{
    if (data == nil)
        data = [[NSMutableData alloc] initWithCapacity:2048];
    
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
    self.image = [UIImage imageWithData:data];
    if (self.caching)
    {
        //[UIImageJPEGRepresentation(self.image, CACHED_IMAGE_JPEG_QUALITY) writeToFile: atomically:YES]; 
    }
    
    [data release], data = nil;
	[connection release], connection = nil;
}

#pragma -
#pragma Caching Methods

- (void)resetCache
{
    
}

#pragma -
#pragma Memory and Clean-up

- (void)dealloc
{
    [super dealloc];
    [placeholderImage release];
    [url release];
}

@end
