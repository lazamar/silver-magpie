/* globals chrome */
/**
 * Detatches the window, creating a popup with the App content
 */
const _user$project$Native_Detach = { // eslint-disable-line no-underscore-dangle, camelcase, max-len, no-unused-vars
  detach: (width, height) => {
    chrome.windows.create({
      url: window.location.pathname,
      width,
      height,
    });
    window.close();
  },
};
