// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XWalkView

public class PresentationSessionHost: XWalkExtension {
    static var presentation: Presentation?
    var url: String?
    var jsprop_id: String?
    var jsprop_state: String = "disconnected"

    weak var peerSession: PresentationSession?

    convenience init(fromJavaScript: AnyObject?, url: String?, id: String?) {
        self.init()
        self.url = url
        self.jsprop_id = id

        if PresentationSessionHost.presentation != nil {
            PresentationSessionHost.presentation!.registerSession(self, id:id!)
            changeState("connected")
        } else {
            print("Failed to register session:\(id) as Presentation object hasn't been initialized")
        }
    }

    deinit {
        if PresentationSessionHost.presentation != nil {
            PresentationSessionHost.presentation!.unregisterSession(jsprop_id!)
        }
    }

    private func changeState(state: String) {
        if (jsprop_state == state) {
            return
        }
        jsprop_state = state
        var js = "var ev = new Event('statechange'); ev.state = '\(jsprop_state)';"
        js += " dispatchEvent(ev);"
        self.evaluateJavaScript(js)
    }

    func jsfunc_send(cid: UInt32, data: AnyObject) {
        if jsprop_state != "connected" {
            return
        }
        peerSession?.onMessage(data)
    }

    func jsfunc_close(cid: UInt32) {
        changeState("disconnected")
    }

    func onMessage(data: AnyObject) {
        if jsprop_state != "connected" {
            return
        }
        var js = "var ev = new Event('message'); ev.data = \(data);"
        js += " dispatchEvent(ev);"
        self.evaluateJavaScript(js)
    }

    func onPeerSessionDestructed() {
        changeState("disconnected")
    }
}