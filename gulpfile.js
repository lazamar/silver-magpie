// List all available tasks
const organiser = require('gulp-organiser');
organiser.registerAll('./tasks', {
  sass: {
    src: 'src/styles/**/*.scss',
    dest: 'dist/styles',
  },
  'copy-static': {
    src: ['src/**/*', '!src/styles/**/*', '!src/elm/**/*'],
    dest: 'dist',
  },
  'build-elm': {
    watch: 'src/elm/**/*',
    src: 'src/elm/Main.elm',
    dest: 'dist/elm',
    moduleName: 'Main',
    ext: 'js',
  },
  'browser-sync': {
    src: '.', // it doesn't matter, it's just so the task object is not ignored.
    reloadOn: ['build-elm', 'copy-static', 'sass'], // reload page when these tasks happen
    startPath: 'dist/pages/index.html',
    baseDir: './',
  },
});
