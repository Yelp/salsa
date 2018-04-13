//
//  NSData+MD5.m
//  Salsa
//
//  Created by Max Rabiciuc on 9/26/17.
//  Copyright © 2017 Yelp. All rights reserved.
//

#import "NSData+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

// This needs to be written in objc instead of swift because it imports CommonCrypto
// Theres no way to import CommonCrypto from swift at the moment
@implementation NSData (MD5)
// Shamelessly taken from http://iosdevelopertips.com/core-services/create-md5-hash-from-nsstring-nsdata-or-file.html
- (nonnull NSString *)MD5 {
  // Create byte array of unsigned chars
  unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

  // Create 16 byte MD5 hash value, store in buffer
  CC_MD5(self.bytes, (unsigned int)self.length, md5Buffer);

  // Convert unsigned char buffer to NSString of hex values
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x",md5Buffer[i]];

  return output;
}
@end

