(function(angular) {
  "use strict";

  var module = angular.module('helpers.fs', []);

  module.factory('FS', function($window) {
    var FS = {};

    FS.File = {
      Image: function(name){
        if (typeof $window.manifest === "undefined" || typeof $window.manifest.img[name] === "undefined") { return name; }
        return $window.manifest.img[name];
      }
    };

    return FS;
  });

})(window.angular);
