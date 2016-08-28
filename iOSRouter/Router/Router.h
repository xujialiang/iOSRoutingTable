//
//  Router.h
//  iOSRouter
//
//  Created by 徐佳良 on 16/8/28.
//  Copyright © 2016年 Credoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RoutingTableItem;

@interface Router : NSObject

+ (NSArray<RoutingTableItem *> *)getRoutingTable;

@end

@interface RoutingTableItem : NSObject

@property (nonatomic,copy) NSString *destination;
@property (nonatomic,copy) NSString *gateway;
@property (nonatomic,copy) NSString *flags;
@property (nonatomic,copy) NSString *refs;
@property (nonatomic,copy) NSString *use;
@property (nonatomic,copy) NSString *mtu;
@property (nonatomic,copy) NSString *expire;
@property (nonatomic,copy) NSString *netif;

@property (nonatomic,copy) NSString *desc;
@end