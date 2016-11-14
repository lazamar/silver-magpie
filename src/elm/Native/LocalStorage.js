function stringify(value) {
  if (value && typeof value.toString === 'function') {
    return value.toString();
  }
  return null;
}

const _user$project$Native_LocalStorage = { // eslint-disable-line no-underscore-dangle, camelcase, max-len, no-unused-vars
  getItem: (key) => {
    const value = window.localStorage.getItem(key);
    return stringify(value);
  },
  setItem: (key, value) => {
    window.setItem(key, stringify(value));
  },
};
