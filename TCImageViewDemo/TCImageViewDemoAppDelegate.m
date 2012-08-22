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
    
    
    //added button to reload image
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button.frame = CGRectMake(10.0, 280.0, 300.0, 30.0);
    [_button setTitle:@"Reload" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _button.enabled = NO;
    _button.alpha = 0.5;
    
    [self.window addSubview:_button];
    
    _image = [[TCImageView alloc] initWithURL:[NSURL URLWithString:@"http://farm6.static.flickr.com/5051/5459247881_ec423d6611_b.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    _image.frame = CGRectMake(10.0, 50.0, 300.0, 200.0);
    _image.caching = YES; // Remove line or change to NO to disable off-line caching
    _image.delegate = self;
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

-(void) buttonTapped: (UIButton *) sender {
    
    
    [_image reloadWithUrl:@"http://farm6.static.flickr.com/5226/5704412488_ee6a6c9124_b.jpg"];
    
    _button.enabled = NO;
    _button.alpha = 0.5;

}

#pragma mark TCImageViewDelegate

-(void)TCImageView:(TCImageView *)view WillUpdateImage:(UIImage *)image {
    
    view.alpha = 0.0;
    
    [UIView animateWithDuration:1.0
                          delay:0.0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^ {
                        
                         view.alpha = 1.0;
                                                  
                     } completion:nil];
}


-(void)TCImageView:(TCImageView *)view FinisehdImage:(UIImage *)image {
    
    _button.enabled = YES;
    _button.alpha = 1.0;

}


-(void)TCImageView:(TCImageView *)view failedWithError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Loading URL" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    [alert show];
    
    _button.enabled = YES;
    _button.alpha = 1.0;
    
}


#pragma mark Memory


@end
