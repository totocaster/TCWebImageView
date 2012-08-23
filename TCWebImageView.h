//
//  TCImageView.h
//  TCImageViewDemo
//


#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY           1.0
#define DOWNLOAD_PROGRESS_INCREMENT_KB      25


@class TCWebImageView;

@protocol TCImageViewDelegate<NSObject>

@optional
-(void)webImageView:(TCWebImageView *)view willUpdateImage:(UIImage *)image;
-(void)webImageView:(TCWebImageView *)view didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)fromCache;
-(void)webImageView:(TCWebImageView *)view failedWithError:(NSError *)error;
-(void)webImageView:(TCWebImageView *)view loadedBytes:(long long)loadedBytes totalBytes:(long long)totalBytes;

@end



@interface TCWebImageView : UIImageView {
    
    // Default
    NSString* _url;
    UIView* _placeholder;
    
    // Networking
    NSURLConnection *_connection;
    NSMutableData *_data;
    long long _expectedFileSize;
    long long _previousDataLengthReading;
    
    // Caching
    BOOL _caching;
    NSTimeInterval _cacheTime;
	
	id<TCImageViewDelegate> __unsafe_unretained _delegate;
    
}
@property (readonly) NSString* url;
@property (readonly) UIView* placeholder;
@property (assign,readwrite,getter = isCaching) BOOL caching;
@property (assign,readwrite) NSTimeInterval cacheTime;

@property (unsafe_unretained) id<TCImageViewDelegate> delegate;

+ (void)resetGlobalCache; // This will remove all cached images managed by any TCImageView instatces
+ (NSString*)cacheDirectoryAddress;

- (id)initWithURL:(NSString *)url placeholderView:(UIView *)placeholderView;
- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image;


- (void)loadImage;
- (void)cancelLoad;

- (void)reloadWithUrl:(NSString *)url;

- (NSString*)cachedImageSystemName;

- (void)resetCache;


@end
