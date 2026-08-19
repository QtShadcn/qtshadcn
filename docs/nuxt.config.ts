export default defineNuxtConfig({
  extends: ['docus'],
  content: {
    build: {
      markdown: {
        highlight: {
          langs: ['qml', 'cpp', 'c']
        }
      }
    }
  }
})
