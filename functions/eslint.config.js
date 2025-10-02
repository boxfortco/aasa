module.exports = [
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2020,
      sourceType: "module",
      globals: {
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        __dirname: "readonly",
        process: "readonly"
      }
    },
    linterOptions: {
      reportUnusedDisableDirectives: true,
    },
    rules: {
      quotes: ["error", "double"],
      "no-unused-vars": ["warn"],
    },
  },
]; 