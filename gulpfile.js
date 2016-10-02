// List all available tasks
const organiser = require('gulp-organiser');
organiser.registerAll('./tasks', {
  sass: {
    src: 'src/styles/**/*.scss',
    dest: 'dist/styles',
  },
  'copy-static': {
    src: ['src/**/*'],
    dest: 'dist',
  },
  'build-elm': {
    src: 'src/js/Main.elm',
    dest: 'dist/js',
    moduleName: 'Main',
    ext: 'js',
  },
});
