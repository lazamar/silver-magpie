/* globals Elm, chrome */

// Creates a pop-up with the app inside of it
const detachWindow = ({ width, height }) => {
    chrome.windows.create(
        {
            url: window.location.pathname,
            width,
            height,
            type: "popup"
        },
        () => document.body.classList.add("is-detached")
    );
    window.close();
};

const localStorageSet = ({ key, value }) => {
    window.localStorage.setItem(key, value);
};

const localStorageGet = ports => key => {
    const value = window.localStorage.getItem(key);
    ports.localStorageReceive.send({ key, value });
};

// Runs a function asynchronously.
// This has the advantage of not breaking the invoking thread
// on error.
const async = func => (...params) => setTimeout(() => func.apply(null, params), 10);

// Register an Elm port.
const registerPort = (ports, func, name) => ports[name].subscribe(async(func));

const setupPorts = ports => {
    // registerPort(ports, localStorageSet, "localStorageSet");
    // registerPort(ports, localStorageGet(ports), "localStorageGet");
    registerPort(ports, detachWindow, "detachWindow");
    return;
};

const container = document.querySelector("#app");
const app = Elm.Main.embed(container);
setupPorts(app.ports);
