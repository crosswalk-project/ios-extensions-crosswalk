// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XWalkView

public class PresentationSession: XWalkExtension {
    weak var peerSessionHost: PresentationSessionHost?

    func jsfunc_send(cid: UInt32, data: AnyObject) {
        peerSessionHost?.onMessage(data)
    }

    func onMessage(data: AnyObject) {
        var js = "var ev = new Event(\"message\"); ev.data = '\(data)';"
        js += " dispatchEvent(ev);"
        self.evaluateJavaScript(js)
    }

    func willDisconnect() {
        peerSessionHost?.onPeerSessionDestructed()
    }
}