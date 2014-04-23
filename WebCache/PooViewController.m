//
//  PooViewController.m
//  WebCache
//
//  Created by crazypoo on 14-4-23.
//  Copyright (c) 2014年 crazypoo. All rights reserved.
//

#import "PooViewController.h"
#import "PooURLCache.h"

@interface PooViewController ()<UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@end

@implementation PooViewController
@synthesize webView = _webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    PooURLCache *urlCache = [[PooURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                           diskCapacity:200 * 1024 * 1024
                                                               diskPath:nil
                                                              cacheTime:0];
    [PooURLCache setSharedURLCache:urlCache];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://qq.com"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}
@end
