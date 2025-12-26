<template>
  <div class="app-shell">
    <header class="topbar">
      <div class="brand">
        <span class="brand-mark">FR</span>
        <div>
          <div class="brand-title">FilmRank</div>
          <div class="brand-subtitle">Discover. Rate. Recommend.</div>
        </div>
      </div>
      <nav class="nav-links">
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/search">Search</RouterLink>
        <RouterLink to="/recommendations">Recommendations</RouterLink>
        <RouterLink to="/profile">Profile</RouterLink>
        <RouterLink v-if="isAdmin" to="/admin">Admin</RouterLink>
        <RouterLink v-if="!isAuthed" to="/login">Login</RouterLink>
        <RouterLink v-if="!isAuthed" to="/register">Register</RouterLink>
        <button v-if="isAuthed" class="button secondary" @click="logout">Logout</button>
      </nav>
    </header>
    <main class="container">
      <RouterView />
    </main>
    <footer class="footer">
      <div class="footer-content">
        <div>
          <div class="footer-title">FilmRank</div>
          <p class="muted">A curated hub for discovering and reviewing films.</p>
        </div>
        <div class="footer-links">
          <span>Copyright (c) 2025 FilmRank</span>
          <span>Privacy</span>
          <span>Terms</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { RouterLink, RouterView } from "vue-router";
import useAuth from "./store/auth.js";

const { clearAuth, isAuthed, isAdmin } = useAuth();

function logout() {
  clearAuth();
}
</script>
