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

app.ports.port_LocalStorage_set.subscribe(string => {
    const appname = "silver-magpie";
    window.localStorage.setItem(appname, string);
});

// Detach
app.ports.port_Detatch_detach.subscribe(({ width, height }) => {
    chrome.windows.create(
        {
            url: window.location.pathname,
            width,
            height,
            type: "popup"
        },
        function() {
            document.body.classList.add("is-detached");
        }
    );
    window.close();
});
