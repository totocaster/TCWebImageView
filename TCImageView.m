//
//  TCImageView.m
//  TCImageViewDemo
//
//  Created by Toto Tvalavadze on 2/17/11.
//  For license please visit: http://totocaster.com/source-code-license/
//

#import "TCImageView.h"
#import <CommonCrypto/CommonDigest.h>


@implementation TCImageView

@synthesize caching, url, placeholderImage, cacheTime;

- (id)initWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)image;
{    
    // Defaults
    placeholderImage = [image retain];
    url = [imageURL retain];
    self.caching = NO;
    self.cacheTime = (double)604800; // 7 days
    
    return [self initWithImage:self.placeholderImage];
}

- (void)loadImage
{
    if (self.caching){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[[TCImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self chachedImageSystemName]]])
        {
            NSDate *mofificationDate = [[fileManager attributesOfItemAtPath:[[TCImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self chachedImageSystemName]] error:nil] objectForKey:NSFileModificationDate];
            if ([mofificationDate timeIntervalSinceNow] > self.cacheTime) {
                // Removes old cache file...
                [self resetCache];
            } else {
                // Loads image from cache without networking
                NSData *localImageData = [NSData dataWithContentsOfFile:[[TCImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self chachedImageSystemName]]];
                self.image = [UIImage imageWithData:localImageData];
                return;
            }
        }
    }
    // Loads image from network if no "return;" is triggered (no cache file found)
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma -
#pragma NSURLConnection Delegates

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{
    if (data == nil)
        data = [[NSMutableData alloc] initWithCapacity:2048];
    
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.image = [UIImage imageWithData:data];
    if (self.caching)
    {
        // Create Cache directory if it doesn't exist
        BOOL isDir = YES;
        if (![fileManager fileExistsAtPath:[TCImageView cacheDirectoryAddress] isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:[TCImageView cacheDirectoryAddress] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        // Write image cache file
        NSError *error;
        NSData *cachedImage = UIImageJPEGRepresentation(self.image, CACHED_IMAGE_JPEG_QUALITY);
       
        [cachedImage writeToFile:[[TCImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self chachedImageSystemName]] options:NSDataWritingAtomic error:&error];
        
        // TODO: error handling
    }
    
    [data release], data = nil;
	[connection release], connection = nil;
}

#pragma -
#pragma Caching Methods


+ (void)resetGlobalCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[TCImageView cacheDirectoryAddress] error:nil];
}

+ (NSString*)cacheDirectoryAddress
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return [documentsDirectoryPath stringByAppendingPathComponent:@"TCImageView-Cache"];
}

- (void)resetCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[[TCImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self chachedImageSystemName]] error:nil];
}

- (NSString*)chachedImageSystemName
{
    const char *concat_str = [[url absoluteString] UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [[hash lowercaseString] stringByAppendingPathExtension:@"jpeg"];
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
