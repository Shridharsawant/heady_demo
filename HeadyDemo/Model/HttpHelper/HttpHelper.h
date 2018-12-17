//
//  HttpHelper.h
//  UTShuttle
//
//  Created by Apple Developer on 19/08/17.
//  Copyright © 2017 Apple Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HttpConnectionDelegate<NSObject>
-(void) getResponse:(NSDictionary *) response withFunction:(NSString *)functionName;
@optional
-(void) getError:(NSDictionary *)error withFunction:(NSString *)functionName;
@end

typedef void(^onResponse)(NSDictionary * response);

@interface HttpHelper : NSObject

@property (weak,nonatomic) id<HttpConnectionDelegate> delegate;
@property (copy, nonatomic) onResponse callback;

-(void) sendRequest :(UIViewController *)controller withFunction:(NSString *)functionName param:(NSMutableDictionary *)param additionalData:(NSMutableDictionary *)data showLoading:(bool) loading;
- (void)sendGetRequest:(UIViewController *)controller withFunction:(NSString *)functionName withUrl:(NSString *)url showLoading:(bool)loading;
-(void) sendBlockResponse:(onResponse) compblock;

@end
