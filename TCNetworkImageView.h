//
//  TCImageView.h
//  TCImageViewDemo
//


#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY 1.0


@class TCNetworkImageView;

@protocol TCImageViewDelegate<NSObject>

@optional
-(void)networkImageView:(TCNetworkImageView *)view willUpdateImage:(UIImage *)image;
-(void)networkImageView:(TCNetworkImageView *)view didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)fromCache;
-(void)networkImageView:(TCNetworkImageView *)view failedWithError:(NSError *)error;
-(void)networkImageView:(TCNetworkImageView *)view loadedBytes:(long long)loadedBytes totalBytes:(long long)totalBytes;

@end



@interface TCNetworkImageView : UIImageView {
    
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
