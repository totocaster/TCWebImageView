//
//  TCImageView.h
//  TCImageViewDemo
//


#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY 1.0


@class TCImageView;

@protocol TCImageViewDelegate<NSObject>

@optional
-(void)TCImageView:(TCImageView *)view willUpdateImage:(UIImage *)image;
-(void)TCImageView:(TCImageView *)view didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)fromCache;
-(void)TCImageView:(TCImageView *)view failedWithError:(NSError *)error;
-(void)TCImageView:(TCImageView *)view loadedBytes:(long long)loadedBytes totalBytes:(long long)totalBytes;

@end



@interface TCImageView : UIImageView {
    
    // Default
    NSString* _url;
    UIView* _placeholder;
    
    // Networking
    NSURLConnection *_connection;
    NSMutableData *_data;
    long long _expectedFileSize;
    
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
