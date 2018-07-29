const gulp = require("gulp");
const organiser = require("gulp-organiser");
const Future = require("fluture");
const fs = require("fs");
const assert = require("assert");
const childProcess = require("child_process");

////////////////////////////////////////////////////////////////////////
// Configuration:
const exampleConfiguration = { // eslint-disable-line
    files: ["./package.json", "src/manifest.json"],
    bumpType: "patch" // "minor" and "major" also accepted.
};
////////////////////////////////////////////////////////////////////////

// ====== FILE SYSTEM =====

const readFile = address =>
    Future((reject, resolve) => {
        fs.readFile(address, "utf8", (err, data) => (err ? reject(err) : resolve(data)));
    });

const writeFile = address => data =>
    Future((reject, resolve) => {
        fs.writeFile(address, data, "utf8", err => (err ? reject(err) : resolve()));
    });

const readJSON = address => readFile(address).map(JSON.parse);

// Run shell command
const exec = command =>
    Future((reject, resolve) => {
        childProcess.exec(command, (err, stdout) => (err ? reject(err) : resolve(stdout)));
    });

// ========== GIT ==========

const gitCurrentTag = exec("git describe --tags");

const gitIsThereAnythingToCommit = exec("git status --porcelain").map(v => !!v);

const gitCommit = message => exec(`git commit -a -m "${message}"`);

const gitCreateTag = tagName => exec(`git tag ${tagName}`);

// ===== VERSION HANDLING =====

const MAJOR = "major";
const MINOR = "minor";
const PATCH = "patch";

const parseNum = n => parseInt(n, 10) || 0;

// Will bump a string version according to a bump type
// MAJOR, 1.1.1 -> 2.1.1
// MINOR, 1.1.1 -> 1.2.1
// PATCH, 1.1.1 -> 1.1.2
const bumpVersion = bump => aVersion => {
    // Leave only numbers with dots.
    // v3.4.5 --> 3.4.5
    const withoutLetters = aVersion.replace(/[^0-9.]/gi, "");
    const numbers = withoutLetters.split(".");
    const major = parseNum(numbers[0]);
    const minor = parseNum(numbers[1]);
    const patch = parseNum(numbers[2]);

    const majorBump = bump === MAJOR ? 1 : 0;
    const minorBump = bump === MINOR ? 1 : 0;
    const patchBump = bump === PATCH ? 1 : 0;

    assert([MAJOR, MINOR, PATCH].includes(bump), "Invalid bump type: " + bump);

    return [major + majorBump, minor + minorBump, patch + patchBump].join(".");
};

const setFileVersion = version => address =>
    readJSON(address)
        .map(obj => Object.assign({}, obj, { version }))
        .map(v => JSON.stringify(v, null, 4))
        .chain(writeFile(address));

module.exports = organiser.register(task => {
    gulp.task(task.name, done => {
        gitIsThereAnythingToCommit
            .chain(
                yes =>
                    yes
                        ? Future.reject(`
                        	-----------------------------------------------
                        	Uncommitted changes in the working tree.
                         	Commit your changes before bumping the version
                         	-----------------------------------------------
                         `)
                        : Future.of()
            )
            .chain(_ => gitCurrentTag)
            .map(bumpVersion(task.bumpType))
            .chain(tag =>
                Future.parallel(Infinity, task.src.map(setFileVersion(tag)))
                    .chain(_ => gitCommit("Version " + tag))
                    .chain(_ => gitCreateTag("v" + tag))
            )
            // Trigger things
            .fork(done, () => done());
    });
});
