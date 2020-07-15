//
// Created by Helder Pinhal on 14/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

#import <Notificare/Notificare-Swift.h>
#import "NotificareBootstrap.h"

@implementation NotificareBootstrap {

}
+ (void)load {
    [NotificareSwizzler setup];
}

@end
