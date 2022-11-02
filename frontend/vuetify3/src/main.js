import { createApp } from 'vue'
import { createVuetify } from 'vuetify'
import { router } from './router'
import App from './App.vue'
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

const vuetify = createVuetify()
const app = createApp(App)
app.use(vuetify).use(router).mount('#app')
