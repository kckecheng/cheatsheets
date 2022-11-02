import { createRouter, createWebHistory } from 'vue-router'
import CaseStatistic from './views/CaseStatistic.vue'
import CaseDetail from './views/CaseDetail.vue'
import About from './views/About.vue'

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      components: {
	content: CaseStatistic
      },
    },
    {
      path: '/detail',
      components: {
	content: CaseDetail
      },
    },
    {
	path: '/about',
	components: {
	  content: About
	},
      },
  ],
})
