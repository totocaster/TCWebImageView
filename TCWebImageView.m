//
//  TCImageView.m
//  TCImageViewDemo
//


#import "TCWebImageView.h"
#import <CommonCrypto/CommonDigest.h>


@implementation TCWebImageView

@synthesize caching = _caching, url = _url, placeholder = _placeholder, cacheTime = _cacheTime, delegate = _delegate;

- (id)initWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)image;
{    

    UIImageView *placeholderView = [[UIImageView alloc] initWithImage:image];
    
    self = [self initWithURL:[imageURL absoluteString] placeholderView:placeholderView];
    
    
    return self;
}

- (id)initWithURL:(NSString *)imageURL placeholderView:(UIView *)placeholderView;
{ 
    self = [super init];
	if (self)
	{
		// Defaults
		_placeholder = nil;
		_url = imageURL;
		self.caching = NO;
		self.cacheTime = (double)604800; // 7 days
		self.delegate = nil;
		
		if (placeholderView != nil)
		{
			_placeholder = placeholderView;
			_placeholder.alpha = _placeholder.alpha < 0.1 ? 1.0 : _placeholder.alpha;
            [self addSubview:_placeholder];
            
		}
	}
    
    return self;
}



- (void)loadImage
{
	//NSLog(@"TCImage loadImage; delegate retain");
    
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
				
				if (_placeholder)
				{
                    if (_placeholder.frame.size.width == 0.0 || _placeholder.frame.size.height == 0.0) {
                        _placeholder.frame = self.frame;
                    }
					[_placeholder setAlpha:0];
				}
				
                if ([self.delegate respondsToSelector:@selector(webImageView:didFinishLoadingImage:fromCache:)]) {
                    [self.delegate webImageView:self didFinishLoadingImage:localImage fromCache:YES];
                } 
                
				//NSLog(@"TCImage loadImage; delegate release");
                
                
                return;
            }
        }
    }
    // Loads image from network if no "return;" is triggered (no cache file found)
    
    _expectedFileSize = 0;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]  ] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self  ];
    
}


-(void)cancelLoad {
    
    if (_connection) {
        
        [_connection cancel];
        
        _expectedFileSize = 0;
        _data = nil;
        _connection = nil;
        
        
    }
}

-(void)reloadWithUrl:(NSString *)url {
    
    
    [self cancelLoad];
    
    self.image = nil;
    if (_placeholder) {
        _placeholder.alpha = 1.0;
    }
    
    _url = nil;
    _url = url;
    
    [self loadImage];
    
}


#pragma - 
#pragma Networking Delegates

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (_delegate && [_delegate respondsToSelector:@selector(webImageView:failedWithError:)]) {
        [_delegate webImageView:self failedWithError:error];
    }
    
    _expectedFileSize = 0;
    
    _data = nil;
    [_connection cancel];
	_connection = nil;
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _expectedFileSize = [response expectedContentLength];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    // NSLog(@"didReceiveData");
    if (_data == nil)
        _data = [[NSMutableData alloc] initWithCapacity:2048];
    
    if ([self.delegate respondsToSelector:@selector(webImageView:loadedBytes:totalBytes:)]) {
        [self.delegate webImageView:self loadedBytes:(long long)_data.length totalBytes:_expectedFileSize];
    }
    
    [_data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	//NSLog(@"connectionDidFinishLoading");
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
	UIImage *imageData = [UIImage imageWithData:_data];
    
    if ([self.delegate respondsToSelector:@selector(webImageView:WillUpdateImage:)]) {
        [self.delegate webImageView:self willUpdateImage:imageData];
    }
    
    self.image = imageData;
	
	if (_placeholder)
	{
		[_placeholder setAlpha:0];
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
		}
    }
	
    
    
    _data = nil;
	[_connection cancel];
    _connection = nil;
	
    if ([self.delegate respondsToSelector:@selector(webImageView:FinisehdImage:)]) {
        [self.delegate webImageView:self didFinishLoadingImage:imageData fromCache:NO];
    }     
    
    
	//NSLog(@"TCImage connectionDidFinishLoading; delegate release");
    
}


#pragma mark -
#pragma mark Caching Methods


+ (void)resetGlobalCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[TCWebImageView cacheDirectoryAddress] error:nil];
}

+ (NSString*)cacheDirectoryAddress
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return [documentsDirectoryPath stringByAppendingPathComponent:@"TCWebImageView-Cache"];
}

- (void)resetCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[[TCWebImageView cacheDirectoryAddress] stringByAppendingPathComponent:[self cachedImageSystemName]] error:nil];
}

- (NSString*)cachedImageSystemName
{
    const char *concat_str = [_url UTF8String];
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
