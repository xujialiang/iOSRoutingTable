//
//  ViewController.m
//  iOSRouter
//
//  Created by 徐佳良 on 16/8/27.
//  Copyright © 2016年 Credoo. All rights reserved.
//

#import "ViewController.h"
#import "Router/Router.h"

@interface ViewController (){
    
    __weak IBOutlet UITextView *txtView;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    __block NSString *showStr = @"Destination        Gateway            Flags        Refs      Use   Netif Expire    \r\n";
    
    NSArray<RoutingTableItem *> *result = [Router getRoutingTable];
    [result enumerateObjectsUsingBlock:^(RoutingTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *dest = [[NSString stringWithFormat:@"%@", obj.destination] stringByPaddingToLength:19 withString:@" " startingAtIndex:0];
        NSString *gateway = [[NSString stringWithFormat:@"%@", obj.gateway] stringByPaddingToLength:19 withString:@" " startingAtIndex:0];
        NSString *flags = [[NSString stringWithFormat:@"%@", obj.flags] stringByPaddingToLength:13 withString:@" " startingAtIndex:0];
        NSString *refs = [[NSString stringWithFormat:@"%@", obj.refs] stringByPaddingToLength:10 withString:@" " startingAtIndex:0];
        NSString *use = [[NSString stringWithFormat:@"%@", obj.use] stringByPaddingToLength:6 withString:@" " startingAtIndex:0];
        NSString *netif = [[NSString stringWithFormat:@"%@", obj.netif] stringByPaddingToLength:6 withString:@" " startingAtIndex:0];
        
        NSString *expire = [[NSString stringWithFormat:@"%@", obj.expire] stringByPaddingToLength:10 withString:@" " startingAtIndex:0];
        
        NSString *itemstr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@\r\n",dest,gateway,flags,refs,use,netif,expire];
        showStr = [showStr stringByAppendingString:itemstr];
    }];

    self->txtView.text = showStr;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
