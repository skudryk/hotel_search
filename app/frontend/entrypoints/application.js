import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createRouter, createWebHistory } from 'vue-router'
import App from '../components/App.vue'
import SearchWidget from '../components/SearchWidget.vue'

// Create Pinia store
const pinia = createPinia()

// Create router
const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: SearchWidget }
  ]
})

// Create and mount the app
const app = createApp(App)
app.use(pinia)
app.use(router)
app.mount('#app')