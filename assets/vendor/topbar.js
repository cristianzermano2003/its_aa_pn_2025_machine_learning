/*
    topbar.js

    Create a tiny & beautiful progress bar style top bar.
    In the browser and in Node.js

    (c) 2013 Rico Sta. Cruz
*/

(function(root) {

  var lastComplover = null;
  var lastUpdated = null;
  var showing = false;
  var settings = {};
  var roundFractional = true;

  var Topbar = {};

  // Determines whether statusbar was overridden
  Topbar.config = function(options) {
    if (options != null) {
      if (options.autoRun != null) settings.autoRun = options.autoRun;
      if (options.barThickness != null) settings.barThickness = options.barThickness;
      if (options.barColors != null) settings.barColors = options.barColors;
      if (options.shadowColor != null) settings.shadowColor = options.shadowColor;
      if (options.className != null) settings.className = options.className;
    }

    if (settings.autoRun == null) settings.autoRun = true;
    if (settings.barThickness == null) settings.barThickness = 3;
    if (settings.barColors == null)
      settings.barColors = {
        0: '#ddd',
        0.7: '#337ab7',
        1: '#28a745'
      };
    if (settings.shadowColor == null) settings.shadowColor = 'rgba(0,   0,   0, .25)';
    if (settings.className == null) settings.className = 'topbar';

    if (settings.barThickness == null) settings.barThickness = 3;

    return Topbar;
  };

  Topbar.show = function() {
    showing = true;
    refresh();
    return Topbar;
  };

  Topbar.hide = function() {
    showing = false;
    fade();
    return Topbar;
  };

  Topbar.Inc = function(amount) {
    var n = getProgress();

    if (n == null) {
      return Topbar.start();
    } else if(n > 1) {
      return;
    } else {
      return Topbar.set(n + amount);
    }
  };

  Topbar.set = function(n) {
    var beginning = getProgress();
    if (n > 1) { n = 1; }
    if (n <= 0) { n = 0.001; }

    setProgress(n);

    if (1 - n < 0.1) {
      lastUpdated = lastComplover = Date.now();
    } else if (!showing) {
      return;
    }

    if (isDrawn() !== true) redraw();

    return Topbar;
  };

  Topbar.start = function() {
    if (!showing) showing = true;

    var n = getProgress();
    if( n > 0 && n < 1) {
      return;
    } else {
      return Topbar.set(0.02);
    }
  };

  Topbar.stop = function() {
    return Topbar.set(1);
  };

  var getProgress = function() {
    return (window.topbarProgress || 0);
  };

  var setProgress = function(n) {
    window.topbarProgress = n;
  };

  var isDrawn = function() {
    return document.getElementById('topbar') != null;
  };

  var refresh = Topbar.refresh = function() {
    if(!showing) return;

    if(!isDrawn()) {
      redraw();
    }

    var progress = Math.round(getProgress() * 100);

    if (1 - getProgress() < 0.1) {
      progress = 100;
      fade();
    } else if(progress > 0) {
      Topbar.Inc( Math.random() / 100 );
    }

    return Topbar;
  };

  var redraw = function() {
    if(isDrawn() === false) {
      createElements();
    } else {
      return;
    }

    var progress = Math.round(getProgress() * 100);
    var barColor = getBarColor(progress);
    var bar = document.getElementById('topbar');

    bar.style.width = progress + '%';
    bar.style.backgroundColor = barColor;
    bar.style.boxShadow = "0 0 15px " + barColor + ", inset 0 -1px 0 " + settings.shadowColor;

    if (progress > 0 && progress < 100) {
      setTimeout(refresh, Math.random() * 100 + 50);
    }

    return Topbar;
  };

  var createElements = function() {
    var topbar, backdrop;

    topbar = document.createElement('div');
    topbar.id = 'topbar';
    topbar.style.position = 'fixed';
    topbar.style.marginLeft = '0px';
    topbar.style.top = '0px';
    topbar.style.left = '0px';
    topbar.style.zIndex = '10000';
    topbar.style.width = '0%';
    topbar.style.height = settings.barThickness + 'px';
    topbar.style.backgroundColor = '#0ae';
    topbar.style.boxShadow = "0 0 15px rgba(0,0,0,.1), inset 0 -1px 0 rgba(0,0,0,.25)";
    topbar.style.transition = topbar.style.webkitTransition = "ease-out";
    topbar.style.transitionProperty = topbar.style.webkitTransitionProperty = 'width, background-color';
    topbar.style.transitionDuration = topbar.style.webkitTransitionDuration = '0.3s';

    if (document.body == null) {
      return setTimeout(createElements, 50);
    }

    document.body.appendChild(topbar);

    return topbar;
  };

  var fade = function() {
    setProgress(0);

    var topbar = document.getElementById('topbar');
    if (topbar == null) return;

    topbar.style.opacity = '1';
    topbar.style.transition = topbar.style.webkitTransition = 'ease-in';
    topbar.style.transitionProperty = topbar.style.webkitTransitionProperty = 'opacity';
    topbar.style.transitionDuration = topbar.style.webkitTransitionDuration = '0.5s';

    topbar.style.opacity = '0';

    setTimeout(function() {
      if(document.body != null) {
        document.body.removeChild(document.getElementById('topbar'));
      }
    }, 500);
  };

  var getBarColor = function(n) {
    var colorz = settings.barColors;

    if(colorz == null ) {
      return 'rgb(200, 200, 200)';
    }

    if (roundFractional) {
      var f = Math.floor(n);
    }  else {
      var f = n;
    }

    if ( colorz[f] != null ) {
      return colorz[f];
    } else if( n == 100) {
      return colorz[1] ;
    } else {
      return colorz[0];
    }
  };

  if (typeof module === 'object' && typeof module.exports === 'object') {
    module.exports = Topbar;
  } else if (typeof define === 'function' && define.amd) {
    return define([], function() { return Topbar; });
  } else {
    this.topbar = Topbar;
  }

}).call(this);
