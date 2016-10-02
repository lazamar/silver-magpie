/* eslint-disable padded-blocks*/

// This task will start all tasks in this folder
const gulp = require('gulp');
const path = require('path');
const browserSync = require('browser-sync').create();
const organiser = require('gulp-organiser');

const DEFAULTS = {
  startPath: 'example',
  baseDir: './',
};

module.exports = organiser.register((task, allTasks) => {
  const { name, reloadOn } = task;
  const startPath = task.startPath || DEFAULTS.startPath;
  const baseDir = task.baseDir || DEFAULTS.baseDir;
  gulp.task(name, () => {

    browserSync.init({
      startPath,
      server: { baseDir },
    });

    // Watch starter path
    gulp.watch(path.join(baseDir, startPath)).on('change', browserSync.reload);

    // Watch other tasks
    const tasksToReloadOn = reloadOn.map(tName => allTasks.find(t => t.name === tName));
    tasksToReloadOn.forEach(t => {
      const globs = t.dest.map(dest => path.join(dest, '**/*'));
      console.log('Reloading on changes at:', globs);
      gulp.watch(globs).on('change', browserSync.reload);
    });

  });
});
