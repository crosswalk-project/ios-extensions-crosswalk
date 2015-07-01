// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var CHANGE_EVENT_NAME = 'change';
var DEFAULT_SESSION_START_EVENT_NAME = 'defaultsessionstart';

var _presentationSessions = {};
var _availabilityList = [];

function Availability() {
    this.value = false;
    this.__defineSetter__("on" + CHANGE_EVENT_NAME, function(callback) {
        if (callback) {
            addEventListener(CHANGE_EVENT_NAME, callback);
        } else {
            removeEventListener(CHANGE_EVENT_NAME, this.onchange);
        }
    });
}

function randomPresentationId() {
    return Math.random().toString(18).slice(2);
}

exports.__defineSetter__("on" + DEFAULT_SESSION_START_EVENT_NAME, function(callback) {
     if (callback) {
         addEventListener(DEFAULT_SESSION_START_EVENT_NAME, callback);
     } else {
         removeEventListener(DEFAULT_SESSION_START_EVENT_NAME, this.ondefaultsessionstart);
     }
});

exports.startSession = function(url, presentationId) {
    var _this = this;

    return new Promise(function(resolve, reject) {
        if (presentationId == undefined) {
            presentationId = randomPresentationId();
            while (_presentationSessions[presentationId] != undefined) {
                presentationId = randomPresentationId();
            }
        } else if (_presentationSessions[presentationId] != undefined) {
            throw new Error("Duplicate Presentation ID");
            reject();
        }

        var presentation = new navigator.presentation.PresentationSession(url, presentationId);
        _presentationSessions[presentationId] = presentation;

        _this.invokeNative('startSession', [url, presentationId, {'resolve': resolve, 'reject': reject}]);

        resolve(presentation);
    });
}

exports.joinSession = function(url, presentationId) {
    return new Promise(function(resolve, reject) {
    });
}

exports.getAvailability = function() {
    var _this = this;
    return new Promise(function(resolve, reject) {
        var resolveWrapper = function(available) {
            var availability = new Availability();
            availability.value = available;
            resolve(availability);
        }
        _this.invokeNative('getAvailability', [{'resolve': resolveWrapper, 'reject': reject}]);
    });
}
