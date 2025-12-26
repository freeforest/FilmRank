<template>
  <section class="page">
    <div class="page-hero compact">
      <div>
        <p class="eyebrow">Profile</p>
        <h1>Personal dashboard</h1>
        <p class="muted">Track ratings, watch history, and what the system recommends next.</p>
      </div>
      <div class="profile-actions">
        <button class="button" :disabled="!isAuthed">Edit profile</button>
        <RouterLink v-if="!isAuthed" class="button secondary" to="/login">Login</RouterLink>
      </div>
    </div>

    <div v-if="!isAuthed" class="card">
      <h3>Sign in to personalize your profile</h3>
      <p class="muted">Log in to view your watch history and recommendations.</p>
    </div>

    <div v-else class="profile-grid">
      <div class="card profile-card">
        <div class="profile-avatar">{{ initials }}</div>
        <div>
          <h2>{{ state.user?.username }}</h2>
          <p class="muted">Role: {{ state.user?.role || "user" }}</p>
          <p class="muted">Email: {{ state.user?.email || "Not provided" }}</p>
        </div>
      </div>

      <div class="stats-card">
        <div class="stat-item">
          <p class="stat-label">Watch sessions</p>
          <p class="stat-value">{{ watchHistory.length }}</p>
        </div>
        <div class="stat-item">
          <p class="stat-label">Ratings</p>
          <p class="stat-value">--</p>
        </div>
        <div class="stat-item">
          <p class="stat-label">Reviews</p>
          <p class="stat-value">--</p>
        </div>
      </div>
    </div>

    <div v-if="isAuthed" class="split">
      <div>
        <h3 class="section-title">Recent watch history</h3>
        <div v-if="watchHistory.length" class="stack">
          <div class="card list-row" v-for="item in watchHistory" :key="item.watch_id">
            <div class="poster tiny" :style="posterStyle(item)"></div>
            <div>
              <p class="list-title">{{ item.title }}</p>
              <p class="muted">Watched {{ formatDate(item.watched_at) }}</p>
            </div>
          </div>
        </div>
        <p v-else class="muted">No watch history yet.</p>
      </div>

      <div>
        <h3 class="section-title">Your recommendations</h3>
        <div v-if="recommendations.length" class="stack">
          <div class="card list-row" v-for="item in recommendations" :key="item.movie_id">
            <div class="poster tiny" :style="posterStyle(item)"></div>
            <div>
              <p class="list-title">{{ item.title }}</p>
              <p class="muted">{{ item.reason || "Recommended for you" }}</p>
            </div>
          </div>
        </div>
        <p v-else class="muted">No recommendations yet. Try rating more movies.</p>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { RouterLink } from "vue-router";
import { api } from "../api.js";
import useAuth from "../store/auth.js";

const { state, isAuthed } = useAuth();
const watchHistory = ref([]);
const recommendations = ref([]);

const initials = computed(() => {
  const name = state.user?.username || "?";
  return name.slice(0, 2).toUpperCase();
});

function posterStyle(item) {
  if (!item.poster_url) {
    return { backgroundImage: "linear-gradient(135deg, #f5d2b8, #f1b58f)" };
  }
  return { backgroundImage: `url(${item.poster_url})` };
}

function formatDate(value) {
  if (!value) return "--";
  const date = new Date(value);
  return date.toLocaleDateString();
}

async function load() {
  if (!isAuthed.value) return;
  try {
    const [history, recs] = await Promise.all([
      api.listWatchHistory(),
      api.listRecommendations()
    ]);
    watchHistory.value = history || [];
    recommendations.value = (recs.items || []).slice(0, 5);
  } catch (err) {
    watchHistory.value = [];
    recommendations.value = [];
  }
}

onMounted(load);
</script>
