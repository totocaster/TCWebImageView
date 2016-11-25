# ⚠️ This is Deprecated Project.

It was never happy with implemetation never used it in production. There are tons of great libraries do to same in a better way. Thanks and happy coding.

---

TCWebImageView is simple and easy to use set of two files which give you UIImageView with built-in networking, error handling and caching support.

*IMPORTANT:* This is pre-release version, thus I do not promise new version to be reverse compatible at this moment.

Key Features
------------
- UIImageVIew with networking
- Error handling
- Download progress
- Placeholder image support  
- Offline caching

Set-up
------
Drag and drop `TCWebImageView.h` and `TCWebImageView.m` into your project, that's all.

Usage
-----
Simply declare `TCWebImageView` instance, assign delegate (that's optional but highly recommended) and add call `-loadImage` method like this:

```objective-c
TCWebImageView *webImageView = [[TCWebImageView alloc] initWithURL:[NSURL URLWithString:@"http://address.of.image/you-want-to-download.jpg"] placeholderImage:[UIImage imageNamed:@"local-placeholder.png"]];
webImageView.delegate = self;
[webImageView loadImage];
[view addSubview:webImageView];
```

By implementing delegates you can: track progress of image loading, do something after image is loaded or manage error of networking.

Those are self-explanatory delegates:
```objective-c
-(void)webImageView:(TCWebImageView *)view willUpdateImage:(UIImage *)image;
-(void)webImageView:(TCWebImageView *)view didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)fromCache;
-(void)webImageView:(TCWebImageView *)view failedWithError:(NSError *)error;
-(void)webImageView:(TCWebImageView *)view loadedBytes:(long long)loadedBytes totalBytes:(long long)totalBytes;
```  

Blocks
------

Instead of using delegates you can use block based `-init` method.

```objective-c
- (id)initWithURL:(NSURL *)url placeholderImage:(UIImage *)image completed:(TCWebImageViewFinishedLoading)complete failed:(TCWebImageViewDidFailLoading)failed loadingProcess:(TCWebImageViewLoadingProcess)loading;
```

Example of usage:
```objective-c
webImageView = [[TCWebImageView alloc] initWithURL:[NSURL URLWithString:@"http://farm6.static.flickr.com/5051/5459247881_ec423d6611_b.jpg"]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                   completed:^(UIImage *image, BOOL fromCache)
                                            {
                                                NSLog(@"Image was loaded using cache: %d",fromCache);
                                            }
                                      failed:^(NSError *error)
                                            {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Loading URL" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                                                
                                                [alert show];
                                            }
                              loadingProcess:^(long long totalBytes, long long bytesDownloaded)
                                            {
                                                _progressBar.progress = (double)bytesDownloaded / (double)totalBytes;
                                            }];

[webImageView loadImage];
```


Caching
-------
To use caching functionality set `caching` property to `YES`; by default caching is not active.

```objective-c
webImageView.caching = YES;
```

You can clear/reset all of `TCWebImageView` cache by calling `+resetGlobalCache` class method.

```objective-c
[TCWebImageView resetGlobalCache];
```

Demo App
--------
This project includes demo app that shows all of it's functionality in a very simple manner.

Licence
-------
You are free to use this code anywhere you like, even in production only if you include follwoing line in you application credits: "YourAppName contains TCWebImageView (https://github.com/totocaster/TCWebImageView) code by Toto Tvalavadze (@totocaster, totocaster@me.com) and it's collaborators from GitHub".

Thanks!
