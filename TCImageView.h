//
//  TCImageView.h
//  TCImageViewDemo
//
//  Created by Toto Tvalavadze on 2/17/11.
//  For license please visit: http://totocaster.com/source-code-license/
//

#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY 1.0

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

+ (void)resetGlobalCache; // This will remove all cached images managed by any TCImageView instatces
+ (NSString*)cacheDirectoryAddress;

- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image;

- (void)loadImage;

- (NSString*)chachedImageSystemName;

- (void)resetCache;

@end
