function stringify(value) {
  if (value !== undefined && typeof value.toString === 'function') {
    return value.toString();
  }
  return '';
}

const _user$project$Native_LocalStorage = { // eslint-disable-line no-underscore-dangle, camelcase, max-len, no-unused-vars

  getItem: (key) => {
    const value = window.localStorage.getItem(key);
    return JSON.stringify(value);
  },

  setItem: ({ key, value }) => {
    window.localStorage.setItem(key, stringify(value));
    return value;
  },

  clear: () => {
    window.localStorage.clear();
    return true;
  },

};
