// Watch all tasks in gulpfile
const gulp = require('gulp');
const organiser = require('gulp-organiser');

module.exports = organiser.register((task, allTasks) => {
  gulp.task(task.name, () => {
    allTasks.forEach(t => {
      console.log(`watching ${t.tasks[0].name}`);
      gulp.watch(t.tasks[0].watch || t.tasks[0].src, [t.name]);
    });
  });
});
