# iOSRoutingTable

## 获取iOS手机路由表
看到surge app里提供了路由表信息，感觉在调试网络时候非常有用。

![](https://raw.githubusercontent.com/xujialiang/iOSRoutingTable/master/demo.jpg)

`
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
`

TODO:
flags 可能不全，已尽最大努力找了linux相关netstat的资料了。

感谢以下开源项目给我的帮助
https://github.com/Shmoopi/iOS-System-Services
https://github.com/ygweric/IOS-RouteAddress