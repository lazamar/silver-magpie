
// Import all tasks
const tasksDir = './tasks';
const requireFolder = require('require-dir-all');
requireFolder(tasksDir, { recursive: true });

// List all available tasks
const gulp = require('gulp');
const shell = require('gulp-shell');
gulp.task('list-tasks', shell.task('gulp --tasks'));
