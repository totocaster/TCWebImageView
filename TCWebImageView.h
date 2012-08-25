//
//  TCImageView.h
//  TCImageViewDemo
//


#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY           1.0
#define DOWNLOAD_PROGRESS_INCREMENT_KB      25


@class TCWebImageView;

// Block Typedefs
typedef void (^TCWebImageViewFinishedLoading)(UIImage *image, BOOL fromCache);
typedef void (^TCWebImageViewDidFailLoading)(NSError *error);
typedef void (^TCWebImageViewLoadingProcess)(long long totalBytes, long long bytesDownloaded);

// Delegate methods (if using a delegate)
@protocol TCImageViewDelegate <NSObject>
@optional
-(void)webImageView:(TCWebImageView *)view willUpdateImage:(UIImage *)image;
-(void)webImageView:(TCWebImageView *)view didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)fromCache;
-(void)webImageView:(TCWebImageView *)view failedWithError:(NSError *)error;
-(void)webImageView:(TCWebImageView *)view loadedBytes:(long long)loadedBytes totalBytes:(long long)totalBytes;
@end


@interface TCWebImageView : UIImageView

// Public Properties
@property NSURL* url;
@property UIView* placeholder;
@property (getter = isCaching) BOOL caching;
@property NSTimeInterval cacheTime;

// Blcoks are also properties, use them before calling -loadImage method
@property (readwrite, copy) TCWebImageViewFinishedLoading finishedLoadingBlock;
@property (readwrite, copy) TCWebImageViewDidFailLoading failedLoadingBlock;
@property (readwrite, copy) TCWebImageViewLoadingProcess loadingProcessBlock;

@property id<TCImageViewDelegate> delegate;


+ (void)resetGlobalCache; // This will remove all cached images managed by any TCWebImageView instatces
+ (NSString*)cacheDirectoryAddress;

// Use those with delegates or set callback block properties before calling -loadImage method
- (id)initWithURL:(NSURL *)url placeholderView:(UIView *)placeholderView;
- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image;

// Inline block callbacks, no delegates requered when using this init
- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image completed:(TCWebImageViewFinishedLoading)complete failed:(TCWebImageViewDidFailLoading)failed loadingProcess:(TCWebImageViewLoadingProcess)loading;


- (void)loadImage;
- (void)cancelLoad;

- (void)reloadWithUrl:(NSURL *)url;
- (void)reloadWithUrlString:(NSString *)urlString;

- (NSString*)cachedImageSystemName;

- (void)resetCache;



@end
