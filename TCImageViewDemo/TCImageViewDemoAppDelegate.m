//
//  TCImageViewDemoAppDelegate.m
//  TCImageViewDemo
//
//  Created by Toto Tvalavadze on 2/17/11.
//  Copyright 2011 63BITS. All rights reserved.
//

#import "TCImageViewDemoAppDelegate.h"

@implementation TCImageViewDemoAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Progress Bar
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressBar.frame = CGRectMake(10.0, 370.0, 300.0, 30.0);
    _progressBar.progress = 0;
    [self.window addSubview:_progressBar];
    
    
    // Button to reload image
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button.frame = CGRectMake(10.0, 280.0, 300.0, 30.0);
    [_button setTitle:@"Reload" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:_button];

    // Buton that clears cache
    _clearCacheButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _clearCacheButton.frame = CGRectMake(10.0, 320.0, 300.0, 30.0);
    [_clearCacheButton setTitle:@"Clear Cache" forState:UIControlStateNormal];
    [_clearCacheButton addTarget:self action:@selector(clearCacheButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:_clearCacheButton];
    
    /*
    _image = [[TCWebImageView alloc] initWithURL:[NSURL URLWithString:@"http://farm6.static.flickr.com/5051/5459247881_ec423d6611_b.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    _image.frame = CGRectMake(10.0, 50.0, 300.0, 200.0);
    _image.caching = YES; // Remove line or change to NO to disable off-line caching
    _image.delegate = self;
    [_image loadImage];
    */
    
    _image = [[TCWebImageView alloc] initWithURL:[NSURL URLWithString:@"http://farm6.static.flickr.com/5051/5459247881_ec423d6611_b.jpg"]
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
    
    _image.frame = CGRectMake(10.0, 50.0, 300.0, 200.0);
    _image.caching = YES; // Remove line or change to NO to disable off-line caching

    [_image loadImage];
     
    [self.window addSubview:_image];
    

    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{

}

#pragma mark Button Events

-(void)buttonTapped:(UIButton *)sender {
    [_image reloadWithUrlString:@"http://farm6.static.flickr.com/5226/5704412488_ee6a6c9124_b.jpg"];
}

-(void)clearCacheButtonTapped:(id)sender
{
    [TCWebImageView resetGlobalCache];
}

#pragma mark TCImageViewDelegate

-(void)webImageView:(TCWebImageView *)view willUpdateImage:(UIImage *)image {
    
    view.alpha = 0.0;
    
    [UIView animateWithDuration:1.0
                          delay:0.0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^ {
                        
                         view.alpha = 1.0;
                                                  
                     } completion:nil];
}


-(void)webImageView:(TCWebImageView *)view didFinishLoadingImage:(UIImage *)image fromCache:(BOOL)fromCache {
    
    NSLog(@"Image was loaded using cache: %d",fromCache);
    
  
}


-(void)webImageView:(TCWebImageView *)view failedWithError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Loading URL" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    [alert show];
    
}

-(void)webImageView:(TCWebImageView *)view loadedBytes:(long long)loadedBytes totalBytes:(long long)totalBytes
{
    _progressBar.progress = (double)loadedBytes / (double)totalBytes;
}


@end
