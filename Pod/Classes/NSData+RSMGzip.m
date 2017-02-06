//
//  NSData+RSMGzip.m
//  Pods
//
//  Created by Justin Yang on 02/11/2016.
//
//

#import "NSData+RSMGzip.h"
#import <zlib.h>

@implementation NSData (RSMGzip)

- (NSData *)rsm_dataByGZipDecompressing {
    if ([self length] == 0) {
        return self;
    }
    
    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));
    
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.avail_in = (unsigned int)[self length];
    zStream.next_in = (Byte *)[self bytes];
    
    OSStatus status;
    if ((status = inflateInit2(&zStream, 15 + 16)) != Z_OK) {
        return nil;
    }
    
    NSUInteger estimatedLength = [self length] * 1.5;
    NSMutableData *decompressedData = [NSMutableData dataWithLength:estimatedLength];
    
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [decompressedData length])) {
            [decompressedData increaseLengthBy:estimatedLength / 2];
        }
        
        zStream.next_out = [decompressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([decompressedData length] - zStream.total_out);
        
        status = inflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));
    
    inflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        return nil;
    }
    
    [decompressedData setLength:zStream.total_out];
    
    return decompressedData;
}

@end
