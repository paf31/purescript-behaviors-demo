"use strict";

var canvas;

exports.createCanvas = function() {
  if (!canvas) {
    canvas = document.createElement("canvas");
    document.body.appendChild(canvas);
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  return canvas;
};
