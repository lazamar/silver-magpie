const taskName = 'transpile';
module.exports = taskName;

const gulp = require('gulp');
const sourcemaps = require('gulp-sourcemaps');
const babel = require('rollup-plugin-babel');
const nodeResolve = require('rollup-plugin-node-resolve');
const commonjs = require('rollup-plugin-commonjs');
const rollup = require('gulp-rollup');
const paths = require('./paths.json');

const origin = paths.js.src;
const destiny = paths.js.dist;

gulp.task(taskName, () => {
	gulp.src(origin)
	.pipe(sourcemaps.init())
	.pipe(rollup({
		// Function names leak to the global namespace. To avoid that,
		// let's just put everything within an immediate function, this way variables
		// are all beautifully namespaced.
		banner: '(function () {',
		footer: '}());',
		entry: origin,
		plugins: [
			nodeResolve({ jsnext: true, main: true }),
			commonjs(),
			babel({
				exclude: 'node_modules/**',
				babelrc: false,
				plugins: ['transform-async-to-generator', 'external-helpers-2'],
				presets: ['es2015-rollup'],
			}),
		],
	}))
	.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(destiny));
});
