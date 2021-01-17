const gulp = require('gulp');
const path = require('path');
const shell = require('gulp-shell');
const organiser = require('gulp-organiser');

module.exports = organiser.register((task) => {
  const {
    ext = 'js',
    src,
    dest,
    moduleName = path.parse(task.src).name,
  } = task;

  const output = path.join(dest, `${moduleName}.${ext}`);
  gulp.task(task.name, shell.task(`elm make ${src} --output=${output}`));
});
