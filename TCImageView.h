//
//  TCImageView.h
//  TCImageViewDemo
//


#import <Foundation/Foundation.h>

#define CACHED_IMAGE_JPEG_QUALITY 1.0


@class TCImageView;

@protocol TCImageViewDelegate<NSObject>

@optional
-(void) TCImageView:(TCImageView *) view WillUpdateImage:(UIImage *)image;
-(void) TCImageView:(TCImageView *) view FinisehdImage:(UIImage *)image;
-(void) TCImageView:(TCImageView *) view failedWithError:(NSError *)error;

@end



@interface TCImageView : UIImageView {
    
    // Default
    NSString* _url;
    UIView* _placeholder;
    
    // Networking
    NSURLConnection *_connection;
    NSMutableData *_data;
    
    // Caching
    BOOL _caching;
    NSTimeInterval _cacheTime;
	
	id<TCImageViewDelegate> _delegate;
    
}
@property (readonly) NSString* url;
@property (readonly) UIView* placeholder;
@property (assign,readwrite,getter = isCaching) BOOL caching;
@property (assign,readwrite) NSTimeInterval cacheTime;

@property (assign) id<TCImageViewDelegate> delegate;

+ (void)resetGlobalCache; // This will remove all cached images managed by any TCImageView instatces
+ (NSString*)cacheDirectoryAddress;

- (id)initWithURL:(NSString *)url placeholderView:(UIView *)placeholderView;
- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image;


- (void)loadImage;
- (void)cancelLoad;

- (void) reloadWithUrl: (NSString *) url;

- (NSString*)cachedImageSystemName;

- (void)resetCache;


@end
