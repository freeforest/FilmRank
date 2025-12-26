import { createRouter, createWebHistory } from "vue-router";
import HomePage from "../pages/HomePage.vue";
import MovieDetail from "../pages/MovieDetail.vue";
import LoginPage from "../pages/LoginPage.vue";
import RegisterPage from "../pages/RegisterPage.vue";
import RecommendationsPage from "../pages/RecommendationsPage.vue";
import AdminPage from "../pages/AdminPage.vue";
import SearchPage from "../pages/SearchPage.vue";
import ProfilePage from "../pages/ProfilePage.vue";

const routes = [
  { path: "/", name: "home", component: HomePage },
  { path: "/search", name: "search", component: SearchPage },
  { path: "/profile", name: "profile", component: ProfilePage },
  { path: "/movies/:id", name: "movie", component: MovieDetail },
  { path: "/login", name: "login", component: LoginPage },
  { path: "/register", name: "register", component: RegisterPage },
  { path: "/recommendations", name: "recommendations", component: RecommendationsPage },
  { path: "/admin", name: "admin", component: AdminPage }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
