// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XWalkView

public class Presentation: XWalkExtension {

    var remoteWindow: UIWindow? = nil
    var remoteViewController: RemoteViewController? = nil
    var sessions: Dictionary<String, PresentationSessionHost> = [:]

    override init() {
        super.init()
        if UIScreen.screens().count == 2 {
            print("external display connected. count:\(UIScreen.screens().count)")
            let remoteScreen: UIScreen = UIScreen.screens()[1];
            createWindowForScreen(remoteScreen)
            sendAvailableChangeEvent(true)
        }

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "screenDidConnect:", name: UIScreenDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "screenDidDisconnect:", name: UIScreenDidDisconnectNotification, object: nil)
    }

    public override func didBindExtension(channel: XWalkChannel!, instance: Int) {
        super.didBindExtension(channel, instance: instance)

        let extensionName = "navigator.presentation.PresentationSession"
        PresentationSessionHost.presentation = self
        if let ext: PresentationSessionHost = XWalkExtensionFactory.createExtension(extensionName) as? PresentationSessionHost {
            channel.webView?.loadExtension(ext, namespace: extensionName)
        }
    }

    func createWindowForScreen(screen: UIScreen) {
        assert(remoteWindow == nil, "remoteWindow should be nil before it is created.")
        remoteWindow = UIWindow(frame: screen.bounds)
        remoteWindow?.screen = screen

        remoteViewController = RemoteViewController()
        remoteWindow?.rootViewController = remoteViewController
        remoteWindow?.hidden = false
    }

    func sendAvailableChangeEvent(isAvailable: Bool) {
        var js = "var ev = new Event(\"change\"); ev.value = \(isAvailable);";
        js += " dispatchEvent(ev);";
        self.evaluateJavaScript(js)
    }

    func screenDidConnect(notification: NSNotification) {
        if let screen = notification.object as? UIScreen {
            createWindowForScreen(screen)
            sendAvailableChangeEvent(true)
        }
    }

    func screenDidDisconnect(notification: NSNotification) {
        if let _ = notification.object as? UIScreen {
            sendAvailableChangeEvent(false)
            remoteWindow?.hidden = true
            remoteViewController?.willDisconnect()
            remoteViewController = nil
            remoteWindow = nil
        }
    }

    func registerSession(sessionHost: PresentationSessionHost, id: String) {
        sessions[id] = sessionHost
    }

    func unregisterSession(id: String) {
        sessions[id] = nil
    }

    func jsfunc_startSession(cid: UInt32, url: String, presentationId: String, _Promise: UInt32) {
        if let sessionHost = sessions[presentationId] {
            remoteViewController?.attachSession(sessionHost)
        }
    }

    func jsfunc_joinSession(cid: UInt32, url: String, presentationId: String, _Promise: UInt32) {
    }

    func jsfunc_getAvailability(cid: UInt32, _Promise: UInt32) {
        invokeCallback(_Promise, key: "resolve", arguments: [UIScreen.screens().count == 2]);
    }
}
