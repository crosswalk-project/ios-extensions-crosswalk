// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var STATE_CHANGE_EVENT_NAME = 'statechange';
var MESSAGE_EVENT_NAME = 'message';

exports.__defineSetter__("on" + STATE_CHANGE_EVENT_NAME, function(callback) {
    if (callback) {
        addEventListener(STATE_CHANGE_EVENT_NAME, callback);
    } else {
        removeEventListener(STATE_CHANGE_EVENT_NAME, this.onstatechange);
    }
});

exports.__defineSetter__("on" + MESSAGE_EVENT_NAME, function(callback) {
    if (callback) {
        addEventListener(MESSAGE_EVENT_NAME, callback);
    } else {
        removeEventListener(MESSAGE_EVENT_NAME, this.onmessage);
    }
});

