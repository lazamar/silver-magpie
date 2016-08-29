const taskName = 'watch';
module.exports = taskName;

const gulp = require('gulp');
const watchSass = require('./watch.sass');

gulp.task(taskName, [watchSass]);
