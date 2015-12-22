// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var initialized = false;

exports.__defineGetter__("initialized", function() {
    return initialized;
});

function DOMError(name, message) {
    this.name = name;
    this.message = message;
}

exports.init = function(options) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (initialized)
            throw new DOMError("InvalidStateError");
        if (options.channel != "Apple")
            throw new DOMError("NotSupportError");
        options.debug = options.debug | true;
        var resolveWrapper = function() {
            initialized = true;
            resolve();
        }
        var rejectWrapper = function() {
            reject(new DOMError("OperationError"));
        }
        _this.invokeNative('init', [options, {'resolve': resolveWrapper, 'reject': rejectWrapper}]);
    });
}

exports.queryProductsInfo = function(productIds) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!initialized)
            throw new DOMError("InvalidStateError");
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('queryProductsInfo', [productIds, {'resolve': resolve, 'reject': rejectWrapper}]);
    });
}

exports.purchase = function(order) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!initialized)
            throw new DOMError("InvalidStateError");
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('purchase', [order, {'resolve': resolve, 'reject': rejectWrapper}]);
    });
}

exports.getReceipt = function() {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (!initialized)
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
        if (!initialized)
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
        if (!initialized)
            throw new DOMError("InvalidStateError");
        var rejectWrapper = function(msg) {
            reject(new DOMError("OperationError", msg));
        }
        _this.invokeNative('restore', [{'resolve': resolve, 'reject': rejectWrapper}]);
    });
}
