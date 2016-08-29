const taskName = 'watch';
module.exports = taskName;

// This task will start all tasks in this folder
const folderToLoad = './watch';

const gulp = require('gulp');
const requireFolder = require('require-dir-all');
const tasksObject = requireFolder(folderToLoad);
const watchTasks = Object.keys(tasksObject).map(k => tasksObject[k]);

gulp.task(taskName, watchTasks);
