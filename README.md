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
Simply declare `TCWebImageView` instance and add it to superview like this:

```objective-c
TCWebImageView *webImageView = [[TCWebImageView alloc] initWithURL:[NSURL URLWithString:@"http://address.of.image/you-want-to-download.jpg"] placeholderImage:[UIImage imageNamed:@"local-placeholder.png"]];

[view addSubview:webImageView];
```



