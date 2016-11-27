/* eslint-disable global-require */
const gulp = require('gulp');
const organiser = require('gulp-organiser');
const exec = require('child_process').exec;


module.exports = organiser.register((task) => {
  const tasksCommand = task.tasks
    .map(t => require(`./${t}`))
    .map(t => t.name)
    .map(t => `gulp ${t}`)
    .join(' && ');

  gulp.task(task.name, (cb) => {
    return exec(tasksCommand, (err, stdout, stderr) => {
      console.log(stdout);
      console.log(stderr);
      cb(err);
    });
  });
});
