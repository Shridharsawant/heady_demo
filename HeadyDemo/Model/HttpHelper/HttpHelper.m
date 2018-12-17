//
//  HttpHelper.m
//  UTShuttle
//
//  Created by Apple Developer on 19/08/17.
//  Copyright © 2017 Apple Developer. All rights reserved.
//

#import "HttpHelper.h"
#import "Reachability.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "UTGo-Swift.h"

@implementation HttpHelper


-(void)sendBlockResponse:(onResponse)compblock
{
    self.callback=compblock;
}

-(void) sendRequest :(UIViewController *)controller withFunction:(NSString *)functionName param:(NSMutableDictionary *)param additionalData:(NSMutableDictionary *)additionalData showLoading:(bool) loading;
{
    if([self isConnected]){
        if(loading) {
            [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
        }
        NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
        
        // Setup the request with URL
        NSURL *urlStr = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[DynamicAPI shared] getBaseApiUrl], functionName]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlStr];
        
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        // Convert POST string parameters to data using UTF8 Encoding
        [urlRequest setHTTPMethod:@"POST"];
        if(param != nil){
            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
            
            [urlRequest setHTTPBody:postData];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        // Create dataTask
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
            if(error!=nil){ //if any error found
                dispatch_async(dispatch_get_main_queue(), ^{
                    // code here
//                    [mbprogre dismiss];
                    [MBProgressHUD hideHUDForView:controller.view animated:YES];
                    NSMutableDictionary *filteredResponse=[[NSMutableDictionary alloc]init];
                    
                    filteredResponse=[[NSMutableDictionary alloc]init];
                    [filteredResponse setValue:[response.URL absoluteString] forKey:@"url"];
                    if(additionalData){
                        [filteredResponse setObject:additionalData forKey:@"additionalData"];
                    }
                    [filteredResponse setValue:error.description forKey:@"ResponseMessage"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self.delegate respondsToSelector:@selector(getError:withFunction:)])
                            [self.delegate getError:filteredResponse withFunction:functionName];
                        if(self.callback)
                        {
                            self.callback(filteredResponse);
                        }
                    });
                    if(controller!=nil)
                        [self showMessage:NSLocalizedString(@"OOPS_ERROR_OCCURRED", @"Message") controller:controller];
                    
                });
            }else{
                if(loading){
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [SVProgressHUD dismiss];
                        [MBProgressHUD hideHUDForView:controller.view animated:YES];
                    });
                }
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:&error];
                NSString* stringData_ = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"===============================================================================\n%@\n%@\n ===============================================================================\n%@===============================================================================",functionName,[self generateJson:param],stringData_);
                NSMutableDictionary *filteredResponse=[[NSMutableDictionary alloc]init];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSInteger statusCode=httpResponse.statusCode;
                if(statusCode==200&&json!=nil){
                    filteredResponse=[[self filterDictionary:json]mutableCopy];
                    if(filteredResponse==nil)
                        filteredResponse=[[NSMutableDictionary alloc]init];
                    [filteredResponse setValue:[httpResponse.URL absoluteString] forKey:@"url"];
                    if(additionalData){
                        [filteredResponse setObject:additionalData forKey:@"additionalData"];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // code here
                        if([self.delegate respondsToSelector:@selector(getResponse:withFunction:)]) {
                            [self.delegate getResponse:filteredResponse withFunction:functionName];
                        }
                        if(self.callback)
                        {
                            self.callback(filteredResponse);
                        }
                    });
                    
                }else{
                    if(controller!=nil)
                        [self showMessage:NSLocalizedString(@"OOPS_ERROR_OCCURRED", @"Message") controller:controller];
                    
                }
                
                
            }
            // Handle your response here
        }];
        
        // Fire the request
        [dataTask resume];
    }
    else{
        if(controller!=nil)
            [self showMessage:NSLocalizedString(@"NO_INTERNET_CONNECTION", @"Message") controller:controller];
    }
}

- (void)sendGetRequest:(UIViewController *)controller withFunction:(NSString *)functionName withUrl:(NSString *)url showLoading:(bool) loading {
    if([self isConnected]){
        if(loading) {
//            [SVProgressHUD show];
            [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
        }
        NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
        // Setup the request with URL
        
        NSURL *urlStr = [NSURL URLWithString:url];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlStr];
        [urlRequest setHTTPMethod:@"GET"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
                                              if(error!=nil){ //if any error found
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      // code here
//                                                      [SVProgressHUD dismiss];
                                                      [MBProgressHUD hideHUDForView:controller.view animated:YES];
                                                      NSMutableDictionary *filteredResponse=[[NSMutableDictionary alloc]init];
                                                      
                                                      filteredResponse=[[NSMutableDictionary alloc]init];
                                                      [filteredResponse setValue:[response.URL absoluteString] forKey:@"url"];
                                                      [filteredResponse setValue:error.description forKey:@"ResponseMessage"];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          if([self.delegate respondsToSelector:@selector(getError:withFunction:)])
                                                              [self.delegate getError:filteredResponse withFunction:functionName];
                                                          if(self.callback)
                                                          {
                                                              self.callback(filteredResponse);
                                                          }
                                                      });
                                                      if(controller!=nil)
                                                          [self showMessage:NSLocalizedString(@"OOPS_ERROR_OCCURRED", @"Message") controller:controller];
                                                      
                                                  });
                                              }else{
                                                  if(loading){
                                                      dispatch_async(dispatch_get_main_queue(), ^{
//                                                          [SVProgressHUD dismiss];
                                                          [MBProgressHUD hideHUDForView:controller.view animated:YES];
                                                      });
                                                  }
                                                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                       options:kNilOptions
                                                                                                         error:&error];
                                                  NSString* stringData_ = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                  NSLog(@"===============================================================================\n%@\n ===============================================================================\n%@===============================================================================",urlStr,stringData_);
                                                  NSMutableDictionary *filteredResponse=[[NSMutableDictionary alloc]init];
                                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                  NSInteger statusCode=httpResponse.statusCode;
                                                  if(statusCode==200 && json!=nil){
                                                      filteredResponse=[[self filterDictionary:json]mutableCopy];
                                                      if(filteredResponse==nil)
                                                          filteredResponse=[[NSMutableDictionary alloc]init];
                                                      [filteredResponse setValue:[httpResponse.URL absoluteString] forKey:@"url"];
                                                      // [filteredResponse setValue:@"Success" forKey:@"ResponseMessage"];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          // code here
                                                          if([self.delegate respondsToSelector:@selector(getResponse:withFunction:)]) {
                                                              [self.delegate getResponse:filteredResponse withFunction:functionName];
                                                          }
                                                          if(self.callback)
                                                          {
                                                              self.callback(filteredResponse);
                                                          }
                                                      });
                                                      
                                                  }else{
                                                      if(controller!=nil)
                                                          [self showMessage:NSLocalizedString(@"OOPS_ERROR_OCCURRED", @"Message") controller:controller];
                                                      
                                                  }
                                                  
                                                  
                                              }
                                              // Handle your response here
                                          }];
        // Fire the request
        [dataTask resume];
    }
    else{
        if(controller!=nil)
            [self showMessage:NSLocalizedString(@"NO_INTERNET_CONNECTION", @"Message") controller:controller];
    }
    
}

-(NSString *)generateJson :(NSMutableDictionary *)contentDictionary
{
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:contentDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    return jsonStr;
}

-(bool)isConnected
{
    //    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    //        return true;
    //    else
    //        return false;
    //check for isReachable here
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    if ([reach currentReachabilityStatus] == NotReachable) {
        NSLog(@"Device is not connected to the internet");
        return NO;
    }
    else {
        NSLog(@"Device is connected to the internet");
        return YES;
    }
    
}

-(void) showMessage:(NSString *)message controller:(UIViewController *)controller
{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"ALERT", @"Message") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"DISMISS", @"Message")
                                                      style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismiss];
    [controller presentViewController:alertController animated:YES completion:nil];
}

- (NSDictionary *) filterDictionary :(NSDictionary *)dict{
    
    
    NSMutableDictionary* mutableDict = [dict mutableCopy];
    for (id key in dict) {
        id object = [dict objectForKey: key];
        if(object == [NSNull null]) {
            [mutableDict setObject:@"" forKey:key];
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            [mutableDict setObject:[self filterDictionary:object] forKey:key];
        }
        else {
            [mutableDict setObject:object forKey:key];
        }
    }
    dict = [mutableDict copy];
    return dict;
}

@end
