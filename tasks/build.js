const gulp = require('gulp');
const organiser = require('gulp-organiser');

const buildElm = require('./build-elm').name;
const copyStatic = require('./copy-static').name;
const sass = require('./sass').name;

module.exports = organiser.register((task) => {
  gulp.task(task.name, [buildElm, copyStatic, sass]);
});
