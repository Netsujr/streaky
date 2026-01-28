/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/**/*.{css,js}'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
