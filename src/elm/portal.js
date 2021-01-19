const appname = "silver-magpie";
const container = document.querySelector('#app');

const local = window.localStorage.getItem(appname);

const app = Elm.Main.init({
    node: container,
    flags: {
        localStorage : local,
        timeNow : Date.now(),
        randomInt :  Math.ceil(Math.random() * 10000)
    }
});

// LocalStorage

app.ports.port_LocalStorage_set.subscribe(value => {
    const appname = "silver-magpie";
    window.localStorage.setItem(appname, stringify(value));
});
