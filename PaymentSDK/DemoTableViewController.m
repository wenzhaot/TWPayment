//
//  DemoTableViewController.m
//  PaymentSDK
//
//  Created by Emar on 5/25/15.
//  Copyright (c) 2015 wenzhaot. All rights reserved.
//

#import "DemoTableViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "Order.h"

#import "WXApi.h"
#import "UPPayPlugin.h"

@interface DemoTableViewController ()<UPPayPluginDelegate>

@end

@implementation DemoTableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"index:%ld", (long)indexPath.row);
    switch (indexPath.row) {
        case 0:
            [self alipay];
            break;
            
        case 1:
            [self wxPay];
            break;
            
        case 2:
            [self uppay];
            break;
            
        default:
            break;
    }
}

- (void)alipay {
    NSString *partner = @"2088611700083020";
    NSString *seller = @"quxuncom@126.com";
    NSString *privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBALqHMUQ7f1cMpfHH \
                             3hkh7sFEnnasc92r/kI9xCYqmXk6awQuNeQxwkhFm2IIu2tArn1RGdcuhv3UaE1R \
                             MNaFNdoqVVB+ylxhPe57ARUQ5jripWKKQvz0tcse460MUMFfCcHXsi4F0xYzjDgj \
                             /ZjlDlR4FpHbhmpWNf7epMjEPXx9AgMBAAECgYBdxmHqX88hQGadK1JpaDnUSF8y \
                             YnjN1Q461zqpxXjrDYeHzoOhebKnCveXTbSLszUGI6POHsIXEpZtaIgZEVeEvtlz \
                             Gebq3s0DkDnb7gis566L6NFBeEIhX3On3r9Nckfr6mU1/7dZt9y/WILNj9keTCBP \
                             idrId6H2giGy5fGsAQJBAOlgFne0yjHaq2I5C+tZyCuv2FtGtPkg6hVEC+3wi8Mw \
                             vRbOkMSaJZeztRJdGfYkZ4dL91RM5pJTwqBGV/DTBkECQQDMnHL4TlDX1pwpDk4E \
                             6SJ/DUGmQjkNjGmuTf1H92CkKpWoe66e8nDhCkasCwzx6FrbuwEiml7q3o0kaoXG \
                             qz89AkBHEPimiUpNNi6cYYzMpXF8RDcZTIXNm4VM5oTPd0HINa5PJKYXCG3MLXBF \
                             YE6Ikvtnyu1NIYHRK2qIDgO3lTtBAkAQmAOO9bMCvint/nX/WfTtPuL7G9XKrn+H \
                             nlWTN5HD3pxCjL1NsLXM2mt+2mqTV9e+iD0AVGqsO55QvL7arNq1AkAGCjKcs88N \
                             k+RpgR2oVjupmxlwWWnBXJq3NZjXQcXfDFEiqbnUu8mTMSmPN1lrEWVpMYpxtHEH \
                             ReEJTj2TqsKp";
    
    
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = @"测试"; //商品标题
    order.productDescription = @"测试vip"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f", 100.f]; //商品价格
    order.notifyURL =  @"http://p.app.yuanfenba.net/pay/alipayNotify"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"paymentsdk";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
    }
}

- (NSString *)generateTradeNO {
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

- (void)wxPay {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = @"10000100";
    request.prepayId= @"1101000000140415649af9fc314aa427";
    request.package = @"Sign=WXPay";
    request.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
    request.timeStamp = 1397527777;
    request.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
    [WXApi sendReq:request];
}

- (void)uppay {
    [UPPayPlugin startPay:@"test" mode:@"01" viewController:self delegate:self];
}

- (void)UPPayPluginResult:(NSString *)result {
    NSLog(@"uppay:%@", result);
}

@end
