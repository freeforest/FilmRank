<template>
  <section class="page">
    <div class="page-hero">
      <div>
        <p class="eyebrow">Movie Search</p>
        <h1>Find the film that matches your mood</h1>
        <p class="muted">Search by title, year, genre, or language, then refine with advanced filters.</p>
      </div>
      <div class="search-panel">
        <input v-model="filters.q" class="input" placeholder="Search by title, actor, or keyword" />
        <button class="button" @click="load">Search</button>
        <button class="button ghost" @click="toggleFilters">
          {{ filtersOpen ? "Hide filters" : "Advanced filters" }}
        </button>
      </div>
    </div>

    <div v-if="filtersOpen" class="filter-card">
      <div class="filter-grid">
        <div>
          <label class="label">Year</label>
          <input v-model="filters.year" class="input" placeholder="2024" />
        </div>
        <div>
          <label class="label">Genre</label>
          <select v-model="filters.genreId" class="input">
            <option value="">All</option>
            <option v-for="genre in genres" :key="genre.genre_id" :value="String(genre.genre_id)">
              {{ genre.name }}
            </option>
          </select>
        </div>
        <div>
          <label class="label">Language</label>
          <input v-model="filters.language" class="input" placeholder="en / zh" />
        </div>
        <div>
          <label class="label">Country</label>
          <input v-model="filters.country" class="input" placeholder="US / CN" />
        </div>
        <div>
          <label class="label">Runtime (min)</label>
          <input v-model="filters.minRuntime" class="input" placeholder="80" />
        </div>
        <div>
          <label class="label">Runtime (max)</label>
          <input v-model="filters.maxRuntime" class="input" placeholder="180" />
        </div>
        <div>
          <label class="label">Sort by</label>
          <select v-model="filters.sort" class="input">
            <option value="latest">Latest</option>
            <option value="top">Hot</option>
          </select>
        </div>
        <div class="filter-actions">
          <button class="button" @click="load">Apply</button>
          <button class="button secondary" @click="reset">Clear filters</button>
        </div>
      </div>
    </div>

    <p class="muted" v-if="message">{{ message }}</p>

    <div class="grid" v-if="movies.length">
      <article class="movie-card" v-for="movie in movies" :key="movie.movie_id">
        <div class="poster" :style="posterStyle(movie)"></div>
        <div class="card-body">
          <div>
            <h3>{{ movie.title }}</h3>
            <p class="muted">{{ movie.year || "-" }} / {{ movie.language || "-" }}</p>
          </div>
          <RouterLink class="button secondary" :to="`/movies/${movie.movie_id}`">View details</RouterLink>
        </div>
      </article>
    </div>
    <p class="muted" v-else-if="!isLoading">No movies found. Try a different query.</p>
  </section>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from "vue";
import { RouterLink, useRoute } from "vue-router";
import { api } from "../api.js";

const route = useRoute();
const movies = ref([]);
const genres = ref([]);
const message = ref("");
const isLoading = ref(true);
const filtersOpen = ref(false);
const filters = reactive({
  q: "",
  year: "",
  genreId: "",
  language: "",
  country: "",
  minRuntime: "",
  maxRuntime: "",
  sort: "latest"
});

function toggleFilters() {
  filtersOpen.value = !filtersOpen.value;
}

function reset() {
  filters.q = "";
  filters.year = "";
  filters.genreId = "";
  filters.language = "";
  filters.country = "";
  filters.minRuntime = "";
  filters.maxRuntime = "";
  filters.sort = "latest";
  load();
}

function posterStyle(movie) {
  if (!movie.poster_url) {
    return { backgroundImage: "linear-gradient(135deg, #f5d2b8, #f1b58f)" };
  }
  return { backgroundImage: `url(${movie.poster_url})` };
}

async function load() {
  message.value = "";
  isLoading.value = true;
  try {
    const params = {};
    if (filters.q) params.q = filters.q;
    if (filters.year) params.year = filters.year;
    if (filters.genreId) params.genre_id = filters.genreId;
    if (filters.language) params.language = filters.language;
    if (filters.country) params.country = filters.country;
    if (filters.minRuntime) params.min_runtime = filters.minRuntime;
    if (filters.maxRuntime) params.max_runtime = filters.maxRuntime;
    if (filters.sort) params.sort = filters.sort;
    movies.value = await api.listMovies(params);
  } catch (err) {
    message.value = err.message;
  } finally {
    isLoading.value = false;
  }
}

async function loadGenres() {
  try {
    genres.value = await api.listGenres();
  } catch (err) {
    message.value = err.message;
  }
}

onMounted(() => {
  if (route.query.q) {
    filters.q = String(route.query.q);
  }
  if (route.query.genre) {
    filters.genreId = String(route.query.genre);
  }
  loadGenres();
  load();
});

watch(
  () => route.query,
  (next) => {
    if (next.q !== undefined) {
      filters.q = String(next.q || "");
    }
    if (next.genre !== undefined) {
      filters.genreId = String(next.genre || "");
    }
    load();
  }
);
</script>

