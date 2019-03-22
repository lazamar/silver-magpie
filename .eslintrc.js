const lineLength = 100;
const tabWidth = 4

module.exports = {
    "extends": ["eslint:recommended", "prettier"],
    "plugins": ["html", "prettier"],// activating esling-plugin-prettier (--fix stuff) 
    "env": {
        "es6": true,
        "browser": true,
        "node": true
    },
    "globals": {},
    "rules": {
        "prettier/prettier":[ "error", 
            {
                "tabWidth": tabWidth,
                "printWidth": lineLength,
            }],
        "no-return-assign": [0],
        "max-len": ["error", { 
            "code": lineLength,
            "tabWidth": tabWidth,
            // "ignoreComments": true,
            "ignoreTrailingComments": true,
            "ignoreUrls": true,
            "ignoreTemplateLiterals": true,
            "ignoreRegExpLiterals": true,
        }],
        "no-multiple-empty-lines": "error",
        "arrow-body-style": ["error", "as-needed"],
        "no-use-before-define": [
            2,
            {
                "functions": true,
                "classes": true,
                "variables": true
            }
        ],
        "no-console": "error",
        "complexity": [1, 4],
        "no-unused-vars": [ 2, { "argsIgnorePattern": "^_" } ],
        "global-require": "error"
    }
}