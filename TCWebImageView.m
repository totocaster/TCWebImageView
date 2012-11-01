//
//  TCImageView.m
//  TCImageViewDemo
//


#import "TCWebImageView.h"
#import <CommonCrypto/CommonDigest.h>

@interface TCWebImageView ()

@property long long expectedFileSize;
@property long long previousDataLengthReading;

@property NSURLConnection *connection;
@property NSMutableData *data;

- (void)setDefaults;

@end

@implementation TCWebImageView

- (id)init
{
    self = [super init];
	if (self)
	{
		[self setDefaults];
	}
    return self;
}

- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image
{
    UIImageView *placeholderView = [[UIImageView alloc] initWithImage:image];
    return [self initWithURL:url placeholderView:placeholderView];
}

- (id)initWithURL:(NSURL *)url placeholderView:(UIView *)placeholderView
{
    self = [super init];
	if (self)
	{
        [self setDefaults];
        
        self.url = url;
        if (placeholderView != nil)
        {
            self.placeholder = placeholderView;
            self.placeholder.alpha = 1.0;
            [self addSubview:self.placeholder];
            
        }
    }
    return self;
}

- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image completed:(TCWebImageViewFinishedLoading)complete failed:(TCWebImageViewDidFailLoading)failed loadingProcess:(TCWebImageViewLoadingProcess)loading
{
    self.finishedLoadingBlock = complete;
    self.failedLoadingBlock = failed;
    self.loadingProcessBlock = loading;
    return [self initWithURL:url placeholderImage:image];
}

- (void)setDefaults
{
    self.caching = NO;
    self.cacheTime = (double)604800; // 7 days
    self.delegate = nil;
}


- (void)loadImage
{
	if (self.caching){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[[TCWebImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]]])
        {
            NSDate *mofificationDate = [[fileManager attributesOfItemAtPath:[[TCWebImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] error:nil] objectForKey:NSFileModificationDate];
            if ([mofificationDate timeIntervalSinceNow] > self.cacheTime) {
                // Removes old cache file...
                [self resetCache];
            } else {
                // Loads image from cache without networking
                NSData *localImageData = [NSData dataWithContentsOfFile:[[TCWebImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]]];
				UIImage *localImage = [UIImage imageWithData:localImageData];
				
                if ([self.delegate respondsToSelector:@selector(webImageView:willUpdateImage:)]) {
                    [self.delegate webImageView:self willUpdateImage:localImage];
                }
				
                self.image = localImage;
				
				if (self.placeholder)
				{
                    if (self.placeholder.frame.size.width == 0.0 || self.placeholder.frame.size.height == 0.0) {
                        self.placeholder.frame = self.frame;
                    }
					[self.placeholder setAlpha:0];
				}
				
                if ([self.delegate respondsToSelector:@selector(webImageView:didFinishLoadingImage:fromCache:)]) {
                    [self.delegate webImageView:self didFinishLoadingImage:localImage fromCache:YES];
                }
                
                if (self.finishedLoadingBlock) {
                    self.finishedLoadingBlock(localImage,YES);
                }
                
                return;
            }
        }
    }
    // Loads image from network if no "return;" is triggered (no cache file found)
    
    self.expectedFileSize = 0;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]  ] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self  ];
    
}


-(void)cancelLoad {
    
    if (self.connection) {
        
        [self.connection cancel];
        
        self.expectedFileSize = 0;
        self.data = nil;
        self.connection = nil;
        
        
    }
}

- (void)reloadWithUrlString:(NSString *)urlString;
{
    [self cancelLoad];
    
    self.image = nil;
    if (self.placeholder) {
        self.placeholder.alpha = 1.0;
    }
    
    self.url = [NSURL URLWithString:urlString];
    
    [self loadImage];
}

- (void)reloadWithUrl:(NSURL *)url
{
    [self reloadWithUrlString:[url absoluteString]];
}


#pragma - 
#pragma Networking Delegates

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webImageView:failedWithError:)]) {
        [self.delegate webImageView:self failedWithError:error];
    }
    
    if (self.failedLoadingBlock) {
        self.failedLoadingBlock(error);
    }
    
    self.expectedFileSize = 0;
    
    self.data = nil;
    [self.connection cancel];
	self.connection = nil;
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedFileSize = [response expectedContentLength];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    // NSLog(@"didReceiveData");
    if (self.data == nil)
        self.data = [[NSMutableData alloc] initWithCapacity:2048];
    
    if (self.data.length - self.previousDataLengthReading > DOWNLOAD_PROGRESS_INCREMENT_KB * 1024) {
        if ([self.delegate respondsToSelector:@selector(webImageView:loadedBytes:totalBytes:)]) {
            [self.delegate webImageView:self loadedBytes:(long long)self.data.length totalBytes:self.expectedFileSize];
        }
        if (self.loadingProcessBlock) {
            self.loadingProcessBlock(self.expectedFileSize,(long long)self.data.length);
        }
        
        _loadingProgress = [NSNumber numberWithFloat:(double)self.data.length / (double)self.expectedFileSize];
        
        self.previousDataLengthReading = self.data.length;
    }
    
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	//NSLog(@"connectionDidFinishLoading");
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
	UIImage *imageData = [UIImage imageWithData:self.data];
    
    if ([self.delegate respondsToSelector:@selector(webImageView:willUpdateImage:)]) {
        [self.delegate webImageView:self willUpdateImage:imageData];
    }
    
    self.image = imageData;
	
	if (self.placeholder)
	{
		[self.placeholder setAlpha:0];
	}
	
    if (self.caching)
    {
        // Create Cache directory if it doesn't exist
        BOOL isDir = YES;
        if (![fileManager fileExistsAtPath:[TCWebImageView cacheDirectoryAddress] isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:[TCWebImageView cacheDirectoryAddress] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        // Write image cache file
        NSError *error;
        NSData *cachedImage = UIImageJPEGRepresentation(self.image, CACHED_IMAGE_JPEG_QUALITY);
        
		@try {
			[cachedImage writeToFile:[[TCWebImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] options:NSDataWritingAtomic error:&error];
		}
		@catch (NSException * e) {
			if ([self.delegate respondsToSelector:@selector(webImageView:failedWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"No image fount in cache" code:001 userInfo:nil];
                [self.delegate webImageView:self failedWithError:error];
            }
            if (self.failedLoadingBlock) {
                self.failedLoadingBlock(error);
            }
		}
    }
	
    
    
    self.data = nil;
	[self.connection cancel];
    self.connection = nil;
	
    if ([self.delegate respondsToSelector:@selector(webImageView:didFinishLoadingImage:fromCache:)]) {
        [self.delegate webImageView:self didFinishLoadingImage:imageData fromCache:NO];
    }
    
    if (self.finishedLoadingBlock) {
        self.finishedLoadingBlock(imageData,NO);
    }
    
}


#pragma mark -
#pragma mark Caching Methods


+ (void)resetGlobalCache
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[TCWebImageView cacheDirectoryAddress] error:&error];
    
}

+ (NSString*)cacheDirectoryAddress
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return [documentsDirectoryPath stringByAppendingPathComponent:@"TCWebImageView-Cache"];
}

- (void)resetCache
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[[TCWebImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] error:&error];
}

- (NSString*)cachedImageSystemName
{
    const char *concat_str = [[self.url absoluteString] UTF8String];
	if (concat_str == nil)
	{
		return @"";
	}
	
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
	
    return [[hash lowercaseString] stringByAppendingPathExtension:@"jpeg"];
}

@end
