TCWebImageView
==============

TCWebImageView is simple and easy to use set of two files which give you UIImageView with built-in networking, error handling and caching support.

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
Simply declare `TCWebImageView` instance, assign delegate (that's optional but highly recommended) and add it to superview like this:

```objective-c
TCWebImageView *webImageView = [[TCWebImageView alloc] initWithURL:[NSURL URLWithString:@"http://address.of.image/you-want-to-download.jpg"] placeholderImage:[UIImage imageNamed:@"local-placeholder.png"]];
webImageView.delegate = self;
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


Caching
-------
To use caching functionality set `caching` property to `YES`; by deffault caching is not in active.

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
You are free to use this code anywhere you like, even in production only if you include follwoing line in you application credits: `YourAppName contains TCWebImageView (https://github.com/totocaster/TCWebImageView) code by Toto Tvalavadze (@totocaster, totocaster@me.com)`.

Thanks!
