//
//  Router.m
//  iOSRouter
//
//  Created by 徐佳良 on 16/8/28.
//  Copyright © 2016年 Credoo. All rights reserved.
//

#import "Router.h"
// ifaddrs
#import <ifaddrs.h>
// inet
#import <arpa/inet.h>
#import <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/ioctl.h>
// route
#if TARGET_IPHONE_SIMULATOR
#include <net/route.h>
#else
#include "route.h"
#endif

@interface Router(){
    struct sockaddr     m_addrs[8];
    struct rt_msghdr2   m_rtm;
}

@end

@implementation Router

-initWithRtm: (struct rt_msghdr2*) rtm
{
    int i;
    struct sockaddr* sa = (struct sockaddr*)(rtm + 1);
    
    memcpy(&(m_rtm), rtm, sizeof(struct rt_msghdr2));
    for(i = 0; i < RTAX_MAX; i++)
    {
        [self setAddr:&(sa[i]) index:i];
    }
    
    return self;
}

-(void) setAddr:(struct sockaddr*)sa index:(int)rtax_index
{
    if(rtax_index >= 0 && rtax_index < RTAX_MAX)
    {
        memcpy(&(m_addrs[rtax_index]), sa, sizeof(struct sockaddr));
    }
}

+ (NSArray<RoutingTableItem *> *)getRoutingTable {
    @try {
        // Set the router array variable with the routing information
        NSMutableArray *routerArray = [Router getRoutes];
        NSMutableArray *res = [NSMutableArray new];
        
        for(int i = 0; i < (int)[routerArray count]; i++)
        {
            // Set the router info
            Router* router = (Router*)[routerArray objectAtIndex:i];
            RoutingTableItem *item = [[RoutingTableItem alloc] init];

            item.destination = [Router getStdFormatSting:[router getDestination]];
            item.gateway = [Router getStdFormatSting:[router getGateway]];
            item.flags = [Router getStdFormatSting:[router getFlags]];
            item.refs = [Router getStdFormatSting:[router getRefs]];
            item.use = [Router getStdFormatSting:[router getUse]];
            item.mtu = [Router getStdFormatSting:[router getMTU]];
            item.expire = [Router getStdFormatSting:[router getExpire]];
            item.netif = [Router getStdFormatSting:[router getNetif]];
            
            [res addObject:item];
        }
        // Return Successful
        return res;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

+(NSString *)getStdFormatSting:(NSString *)str{
    return [[str stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\x02" withString:@""];
}

-(nullable NSString*) getFlags{
    NSString *result = [[NSString alloc] init];
    if(m_rtm.rtm_flags & RTF_UP){
        result = [result stringByAppendingString:@"U"];
    }
    if(m_rtm.rtm_flags & RTF_GATEWAY){
        result = [result stringByAppendingString:@"G"];
    }
    if(m_rtm.rtm_flags & RTF_HOST){
        result = [result stringByAppendingString:@"H"];
    }
    if(m_rtm.rtm_flags & RTF_REJECT){
        result = [result stringByAppendingString:@"R"];
    }
    if(m_rtm.rtm_flags & RTF_DYNAMIC){
        result = [result stringByAppendingString:@"D"];
    }
    if(m_rtm.rtm_flags & RTF_MODIFIED){
        result = [result stringByAppendingString:@"M"];
    }
    if(m_rtm.rtm_flags & RTF_DONE){
        result = [result stringByAppendingString:@"d"];
    }
    if(m_rtm.rtm_flags & RTF_MULTICAST){
        result = [result stringByAppendingString:@"m"];
    }
    if(m_rtm.rtm_flags & RTF_CLONING){
        result = [result stringByAppendingString:@"C"];
    }
    if(m_rtm.rtm_flags & RTF_PRCLONING){
        result = [result stringByAppendingString:@"c"];
    }
    if(m_rtm.rtm_flags & RTF_LLINFO){
        result = [result stringByAppendingString:@"L"];
    }
    if(m_rtm.rtm_flags & RTF_WASCLONED){
        result = [result stringByAppendingString:@"W"];
    }
    if(m_rtm.rtm_flags & RTF_STATIC){
        result = [result stringByAppendingString:@"S"];
    }
    if(m_rtm.rtm_flags & RTF_BLACKHOLE){
        result = [result stringByAppendingString:@"B"];
    }
    if(m_rtm.rtm_flags & RTF_PROTO1){
        result = [result stringByAppendingString:@"1"];
    }
    if(m_rtm.rtm_flags & RTF_PROTO2){
        result = [result stringByAppendingString:@"2"];
    }
    if(m_rtm.rtm_flags & RTF_PROTO3){
        result = [result stringByAppendingString:@"2"];
    }
    if(m_rtm.rtm_flags & RTF_BROADCAST){
        result = [result stringByAppendingString:@"b"];
    }
    if(m_rtm.rtm_flags & RTF_ROUTER){
        result = [result stringByAppendingString:@"r"];
    }
    if(m_rtm.rtm_flags & RTF_IFSCOPE){
        result = [result stringByAppendingString:@"l"];
    }
    
    
    if(m_rtm.rtm_flags & RTF_XRESOLVE){
        result = [result stringByAppendingString:@"X"];
    }
    
    if(m_rtm.rtm_flags & RTF_IFREF){
        result = [result stringByAppendingString:@"i"];
    }
    
    return result;
}

+ (NSMutableArray*) getRoutes
{
    NSMutableArray* routeArray = [NSMutableArray array];
    Router* route = nil;
    
    size_t len;
    int mib[6];
    char *buf;
    register struct rt_msghdr2 *rtm;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = PF_INET;
    mib[4] = NET_RT_DUMP2;
    mib[5] = 0;
    
    sysctl(mib, 6, NULL, &len, NULL, 0);
    buf = malloc(len);
    if (buf && sysctl(mib, 6, buf, &len, NULL, 0) == 0)
    {
        for (char * ptr = buf; ptr < buf + len; ptr += rtm->rtm_msglen)
        {
            rtm = (struct rt_msghdr2 *)ptr;
            route = [Router getRoute:rtm];
            if(route != nil)
            {
                [routeArray addObject:route];
            }
        }
    }
    
    free(buf);
    
    return routeArray;
}

+ (nullable Router*) getRoute:(struct rt_msghdr2 *)rtm
{
    struct sockaddr* dst_sa = (struct sockaddr *)(rtm + 1);
    Router* route = nil;
    
    if(rtm->rtm_addrs & RTA_DST)
    {
        if(dst_sa->sa_family == AF_INET && !((rtm->rtm_flags & RTF_WASCLONED) && (rtm->rtm_parentflags & RTF_PRCLONING)))
        {
            route = [[Router alloc] initWithRtm:rtm];
        }
    }
    return route;
}

-(nullable NSString*) getGateway
{
    return [self getAddrStringByIndex:RTAX_GATEWAY];
}
-(nullable NSString*) getDestination
{
    return [self getAddrStringByIndex:RTAX_DST];
}

-(nullable NSString*) getRefs
{
    return [NSString stringWithFormat:@"%d",m_rtm.rtm_refcnt];
}

-(nullable NSString*) getUse
{
    return [NSString stringWithFormat:@"%d",m_rtm.rtm_use];
}

-(nullable NSString*) getMTU
{
    return [NSString stringWithFormat:@"%d",m_rtm.rtm_rmx.rmx_mtu];
}

-(nullable NSString*) getExpire
{
    int diff = m_rtm.rtm_rmx.rmx_expire-[[NSDate new] timeIntervalSince1970];
    if (diff<0) {
        diff = 0;
    }
    return [NSString stringWithFormat:@"%d",diff];
}

-(nullable NSString*) getAddrStringByIndex: (int)rtax_index
{
    NSString * routeString = nil;
    
    struct sockaddr* sa = &(m_addrs[rtax_index]);
    int flagVal = 1 << rtax_index;
    
    if(!(m_rtm.rtm_addrs & flagVal))
    {
        return nil;
    }
    
    if(rtax_index >= 0 && rtax_index < RTAX_MAX)
    {
        switch(sa->sa_family)
        {
            case AF_INET:
            {
                struct sockaddr_in* si = (struct sockaddr_in *)sa;
                if(si->sin_addr.s_addr == INADDR_ANY)
                    routeString = @"default";
                else
                    routeString = [NSString stringWithCString:(char *)inet_ntoa(si->sin_addr) encoding:NSASCIIStringEncoding];
            }
                break;
                
            case AF_LINK:
            {
                struct sockaddr_dl* sdl = (struct sockaddr_dl*)sa;
                if(sdl->sdl_nlen + sdl->sdl_alen + sdl->sdl_slen == 0)
                {
                    routeString = [NSString stringWithFormat: @"link #%d", sdl->sdl_index];
                }
                else
                    routeString = [NSString stringWithCString:link_ntoa(sdl) encoding:NSASCIIStringEncoding];
            }
                break;
                
            default:
            {
                char a[3 * sa->sa_len];
                char *cp;
                char *sep = "";
                int i;
                
                if(sa->sa_len == 0)
                {
                    routeString = nil;
                }
                else
                {
                    a[0] = '\0';
                    for(i = 0, cp = a; i < sa->sa_len; i++)
                    {
                        cp += sprintf(cp, "%s%02x", sep, (unsigned char)sa->sa_data[i]);
                        sep = ":";
                    }
                    routeString = [NSString stringWithCString:a encoding:NSASCIIStringEncoding];
                }
            }
        }
    }
    
    return routeString;
}

-(nullable NSString*)getNetif{
    int mib[6];
    char * buf;
    size_t lenp;
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = 0;  /* only addresses of this family */
    mib[4] = NET_RT_IFLIST;
    mib[5] = m_rtm.rtm_index;  /* interface index, or 0 */
    if(sysctl(mib, 6, NULL, &lenp, NULL, 0) < 0) /* 第一次调用sysctl时第三个参数为空，在lenp指向的变量中返回存放所有结构信息要用的缓冲区的大小 */
        return(NULL);
    if((buf = malloc(lenp)) == NULL) /* 给缓冲区分配空间 */
        return(NULL);
    
    sysctl(mib, 6, buf, &lenp, NULL, 0);
    interfaceMsgStruct = (struct if_msghdr *) buf;
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    NSString *result = [NSString stringWithCString:socketStruct->sdl_data encoding:NSUTF8StringEncoding];
    
    free(buf);
    
    
    return [NSString stringWithFormat:@"%@",result];
}

@end

@implementation  RoutingTableItem
-(NSString *)desc{
    return [NSString stringWithFormat:@"Destination:%@,Gateway:%@,Flags:%@,Refs:%@,Use:%@,MTU:%@,Netif:%@,Expire:%@",self.destination,self.gateway,self.flags,self.refs,self.use,self.mtu,self.netif,self.expire ];
}
@end
