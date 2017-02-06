//
//  NSData+RSMGzip.h
//  Pods
//
//  Created by Justin Yang on 02/11/2016.
//
//

#import <Foundation/Foundation.h>

@interface NSData (RSMGzip)

- (NSData *)rsm_dataByGZipDecompressing;

@end
