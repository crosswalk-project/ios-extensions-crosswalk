// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var _initialized = false;

exports.__defineGetter__("intialized", function() {
    return _initialized;
});

function DOMError(name, message) {
    this.name = name;
    this.message = message;
}

exports.init = function(options) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (_initialized)
            throw new DOMError("InvalidStateError");
        if (options.channel != "AppleStore")
            throw new DOMError("NotSupportError");
        options.debug = options.debug | true;
        var resolveWrapper = function() {
            _initialized = true;
            resolve();
        }
        var rejectWrapper = function() {
            reject(new DOMError("OperationError"));
        }
        _this.invokeNative('init', [JSON.stringify(options), {'resolve': resolveWrapper, 'reject': rejectWrapper}]);
    });
}

exports.queryProductsInfo = function(productIds) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!_initialized)
            throw new DOMError("InvalidStateError");
        var resolveWrapper = function(msg) {
            resolve(JSON.parse(msg));
        }
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('queryProductsInfo', [JSON.stringify(productIds), {'resolve': resolveWrapper, 'reject': rejectWrapper}]);
    });
}

exports.purchase = function(order) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!_initialized)
            throw new DOMError("InvalidStateError");
        var resolveWrapper = function(msg) {
            resolve(JSON.parse(msg));
        }
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('purchase', [JSON.stringify(order), {'resolve': resolveWrapper, 'reject': rejectWrapper}]);
    });
}

exports.getReceipt = function() {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!_initialized)
            throw new DOMError("InvalidStateError");
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('getReceipt', [{'resolve': resolve, 'reject': rejectWrapper}]);
    });
}

exports.validateReceipt = function() {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!_initialized)
            throw new DOMError("InvalidStateError");
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('validateReceipt', [{'resolve': resolve, 'reject': rejectWrapper}]);
    });
}

exports.restore = function() {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!_initialized)
            throw new DOMError("InvalidStateError");
        var resolveWrapper = function(msg) {
            resolve(JSON.parse(msg));
        }
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('restore', [{'resolve': resolveWrapper, 'reject': rejectWrapper}]);
    });
}
