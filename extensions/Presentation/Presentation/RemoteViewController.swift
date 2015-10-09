// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit
import WebKit
import XWalkView

class RemoteViewController: UIViewController {
    var webview: XWalkView?
    weak var session: PresentationSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        webview = XWalkView(frame: view.frame, configuration: WKWebViewConfiguration())
        webview?.autoresizingMask = UIViewAutoresizing.FlexibleWidth.intersect(UIViewAutoresizing.FlexibleHeight)
        webview?.scrollView.bounces = false
        view.addSubview(webview!)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var rotateAngle: Double = 0;
        switch UIApplication.sharedApplication().statusBarOrientation {
        case UIInterfaceOrientation.LandscapeLeft:
            rotateAngle = 90.0
            break;
        case UIInterfaceOrientation.LandscapeRight:
            rotateAngle = -90.0
            break;
        case UIInterfaceOrientation.PortraitUpsideDown:
            rotateAngle = 180.0
            break;
        default:
            return;
        }

        var transform = CGAffineTransformRotate(webview!.transform, CGFloat(rotateAngle / 180.0 * M_PI))
        let distance = (self.view.frame.height - self.view.frame.width) / 2
        transform = CGAffineTransformTranslate(transform, distance, distance)
        webview?.transform = transform
    }

    func attachSession(sessionHost: PresentationSessionHost) {
        let name = "navigator.presentation.session"
        if let ext: PresentationSession = XWalkExtensionFactory.createExtension(name) as? PresentationSession {
            sessionHost.peerSession = ext
            ext.peerSessionHost = sessionHost
            webview?.loadExtension(ext, namespace: name)
            self.session = ext
        }

        if let root = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent("www") {
            var error: NSError?
            let start_url = root.URLByAppendingPathComponent(sessionHost.url!)
            if start_url.checkResourceIsReachableAndReturnError(&error) {
                webview?.loadFileURL(start_url, allowingReadAccessToURL: root)
            } else {
                webview?.loadHTMLString(error!.description, baseURL: nil)
            }
        }
    }

    func willDisconnect() {
        session?.willDisconnect()
    }
}
