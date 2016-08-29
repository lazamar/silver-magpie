const taskName = 'sass';
module.exports = taskName;

const gulp = require('gulp');
const sass = require('gulp-sass');
const paths = require('./paths.json');

const origin = paths.styles.src;
const destiny = paths.styles.dist;

gulp.task(taskName, () => {
	gulp.src(origin)
		.pipe(sass().on('error', sass.logError))
		.pipe(gulp.dest(destiny));
});
