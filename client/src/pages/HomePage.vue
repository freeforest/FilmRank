<template>
  <section class="page">
    <div class="hero">
      <div class="hero-copy">
        <p class="eyebrow">FilmRank Homepage</p>
        <h1>Curated films, tailored to your next watch.</h1>
        <p class="muted">Search by title, genre, or language. Dive into trending picks and personalized lists.</p>
        <div class="hero-search">
          <input v-model="query" class="input" placeholder="Search movies, actors, or genres" />
          <button class="button" @click="goSearch">Search</button>
        </div>
        <div class="chip-row">
          <button
            v-for="genre in genres"
            :key="genre.genre_id"
            class="chip"
            @click="goGenre(genre.genre_id)"
          >
            {{ genre.name }}
          </button>
        </div>
      </div>
      <div class="hero-panel">
        <div class="hero-card">
          <p class="eyebrow">Today</p>
          <h3>Personal mix</h3>
          <p class="muted">A blend of recency, ratings, and what people with similar tastes love.</p>
          <RouterLink class="button secondary" to="/recommendations">Open recommendations</RouterLink>
        </div>
        <div class="hero-card highlight">
          <p class="eyebrow">Live</p>
          <h3>Hot right now</h3>
          <p class="muted">The most watched titles in the FilmRank community.</p>
        </div>
      </div>
    </div>

    <div v-if="message" class="muted">{{ message }}</div>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Featured recommendations</h2>
        <RouterLink class="link" to="/recommendations">See all</RouterLink>
      </div>
      <div class="grid" v-if="featured.length">
        <article class="movie-card" v-for="item in featured" :key="item.movie_id">
          <div class="poster" :style="posterStyle(item)"></div>
          <div class="card-body">
            <div>
              <h3>{{ item.title }}</h3>
              <p class="muted">{{ item.reason || "Picked for you" }}</p>
            </div>
            <RouterLink class="button secondary" :to="`/movies/${item.movie_id}`">Details</RouterLink>
          </div>
        </article>
      </div>
      <p class="muted" v-else>No recommendations yet.</p>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Hot movies</h2>
        <RouterLink class="link" to="/search">Browse all</RouterLink>
      </div>
      <div class="grid" v-if="hot.length">
        <article class="movie-card" v-for="movie in hot" :key="movie.movie_id">
          <div class="poster" :style="posterStyle(movie)"></div>
          <div class="card-body">
            <div>
              <h3>{{ movie.title }}</h3>
              <p class="muted">{{ movie.year || "-" }} / {{ movie.language || "-" }}</p>
            </div>
            <RouterLink class="button secondary" :to="`/movies/${movie.movie_id}`">Details</RouterLink>
          </div>
        </article>
      </div>
      <p class="muted" v-else>No movies loaded yet.</p>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Fresh arrivals</h2>
        <RouterLink class="link" to="/search">Search more</RouterLink>
      </div>
      <div class="grid" v-if="latest.length">
        <article class="movie-card" v-for="movie in latest" :key="movie.movie_id">
          <div class="poster" :style="posterStyle(movie)"></div>
          <div class="card-body">
            <div>
              <h3>{{ movie.title }}</h3>
              <p class="muted">{{ movie.year || "-" }} / {{ movie.language || "-" }}</p>
            </div>
            <RouterLink class="button secondary" :to="`/movies/${movie.movie_id}`">Details</RouterLink>
          </div>
        </article>
      </div>
      <p class="muted" v-else>No movies loaded yet.</p>
    </section>
  </section>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { RouterLink, useRouter } from "vue-router";
import { api } from "../api.js";
import useAuth from "../store/auth.js";

const router = useRouter();
const { isAuthed } = useAuth();

const query = ref("");
const featured = ref([]);
const hot = ref([]);
const latest = ref([]);
const genres = ref([]);
const message = ref("");

function posterStyle(item) {
  if (!item.poster_url) {
    return { backgroundImage: "linear-gradient(135deg, #f5d2b8, #f1b58f)" };
  }
  return { backgroundImage: `url(${item.poster_url})` };
}

function goSearch() {
  router.push({ path: "/search", query: query.value ? { q: query.value } : {} });
}

function goGenre(id) {
  router.push({ path: "/search", query: { genre: id } });
}

async function load() {
  message.value = "";
  try {
    const [movies, latestMovies, genreList] = await Promise.all([
      api.listMovies(),
      api.listMovies({ sort: "latest" }),
      api.listGenres()
    ]);
    hot.value = (movies || []).slice(0, 6);
    latest.value = (latestMovies || []).slice(0, 6);
    genres.value = (genreList || []).slice(0, 8);

    if (isAuthed.value) {
      const data = await api.listRecommendations();
      featured.value = (data.items || []).slice(0, 6);
    } else {
      featured.value = (movies || []).slice(0, 6).map((movie) => ({
        ...movie,
        reason: "Sign in for personalized picks"
      }));
    }
  } catch (err) {
    message.value = err.message;
  }
}

onMounted(load);
</script>

