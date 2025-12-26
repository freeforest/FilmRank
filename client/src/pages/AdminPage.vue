<template>
  <section class="page">
    <div class="page-hero compact">
      <div>
        <p class="eyebrow">Admin Console</p>
        <h1>Manage the FilmRank catalog</h1>
        <p class="muted">Moderate users, update movies, and generate recommendation batches.</p>
      </div>
      <div class="profile-actions">
        <button class="button" @click="loadUsers">Refresh users</button>
      </div>
    </div>

    <p class="muted" v-if="message">{{ message }}</p>

    <div class="admin-grid">
      <div class="card">
        <h3>Movie management</h3>
        <div class="form-stack">
          <input v-model="movieTitle" class="input" placeholder="Title" />
          <input v-model="movieYear" class="input" placeholder="Year" />
          <input v-model="movieLanguage" class="input" placeholder="Language" />
          <input v-model="moviePoster" class="input" placeholder="Poster URL" />
          <textarea v-model="movieDescription" class="input" rows="3" placeholder="Description"></textarea>
          <button class="button" @click="createMovie">Create movie</button>
        </div>
        <div class="divider"></div>
        <div class="form-stack">
          <input v-model="updateMovieId" class="input" placeholder="Movie ID" />
          <input v-model="updateTitle" class="input" placeholder="New title" />
          <input v-model="updateYear" class="input" placeholder="New year" />
          <button class="button secondary" @click="updateMovie">Update movie</button>
        </div>
        <div class="divider"></div>
        <div class="form-stack">
          <input v-model="bindMovieId" class="input" placeholder="Movie ID" />
          <input v-model="bindGenres" class="input" placeholder="Genre IDs (comma-separated)" />
          <button class="button secondary" @click="bindMovieGenres">Bind genres</button>
        </div>
      </div>

      <div class="card">
        <h3>User management</h3>
        <div class="form-row">
          <input v-model="userQuery" class="input" placeholder="Search username/email" />
          <button class="button" @click="loadUsers">Search</button>
        </div>
        <div class="stack" v-if="users.length">
          <div v-for="user in users" :key="user.user_id" class="list-row">
            <div>
              <p class="list-title">{{ user.username }}</p>
              <p class="muted">{{ user.email || "No email" }}</p>
            </div>
            <button class="button ghost" @click="toggleUser(user)">
              {{ user.status === "active" ? "Ban" : "Unban" }}
            </button>
          </div>
        </div>
        <p v-else class="muted">No users loaded.</p>
      </div>

      <div class="card">
        <h3>Review moderation</h3>
        <div class="form-stack">
          <input v-model="reviewId" class="input" placeholder="Review ID" />
          <select v-model="reviewStatus" class="input">
            <option value="visible">Visible</option>
            <option value="hidden">Hidden</option>
          </select>
          <button class="button" @click="updateReviewStatus">Apply status</button>
        </div>
      </div>

      <div class="card">
        <h3>Genre management</h3>
        <div class="form-row">
          <input v-model="genreName" class="input" placeholder="Genre name" />
          <button class="button" @click="createGenre">Create</button>
        </div>
        <div class="form-row">
          <input v-model="genreId" class="input" placeholder="Genre ID" />
          <input v-model="genreUpdate" class="input" placeholder="New name" />
          <button class="button secondary" @click="updateGenre">Update</button>
        </div>
      </div>

      <div class="card">
        <h3>Rating policy</h3>
        <div class="form-row">
          <input v-model="policyMin" class="input" placeholder="Min score" />
          <input v-model="policyMax" class="input" placeholder="Max score" />
          <input v-model="policyStep" class="input" placeholder="Step" />
          <button class="button" @click="updatePolicy">Apply</button>
        </div>
      </div>

      <div class="card">
        <h3>Generate recommendations</h3>
        <div class="form-row">
          <select v-model="algo" class="input" style="max-width: 200px;">
            <option value="hot">Hot</option>
            <option value="content">Content</option>
            <option value="cf">CF</option>
            <option value="hybrid">Hybrid</option>
          </select>
          <input v-model="topN" class="input" placeholder="Top N" />
          <button class="button" @click="generate">Generate</button>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from "vue";
import { api } from "../api.js";

const message = ref("");

const movieTitle = ref("");
const movieYear = ref("");
const movieLanguage = ref("");
const moviePoster = ref("");
const movieDescription = ref("");

const updateMovieId = ref("");
const updateTitle = ref("");
const updateYear = ref("");

const bindMovieId = ref("");
const bindGenres = ref("");

const genreName = ref("");
const genreId = ref("");
const genreUpdate = ref("");

const policyMin = ref("0");
const policyMax = ref("10");
const policyStep = ref("0.5");

const algo = ref("hot");
const topN = ref("10");

const userQuery = ref("");
const users = ref([]);

const reviewId = ref("");
const reviewStatus = ref("hidden");

async function createMovie() {
  message.value = "";
  try {
    await api.admin.createMovie({
      title: movieTitle.value,
      year: movieYear.value || null,
      language: movieLanguage.value || null,
      poster_url: moviePoster.value || null,
      description: movieDescription.value || null
    });
    message.value = "Movie created";
    movieTitle.value = "";
    movieYear.value = "";
    movieLanguage.value = "";
    moviePoster.value = "";
    movieDescription.value = "";
  } catch (err) {
    message.value = err.message;
  }
}

async function updateMovie() {
  message.value = "";
  try {
    await api.admin.updateMovie(updateMovieId.value, {
      title: updateTitle.value || undefined,
      year: updateYear.value || undefined
    });
    message.value = "Movie updated";
    updateMovieId.value = "";
    updateTitle.value = "";
    updateYear.value = "";
  } catch (err) {
    message.value = err.message;
  }
}

async function bindMovieGenres() {
  message.value = "";
  try {
    const ids = bindGenres.value
      .split(",")
      .map((id) => Number(id.trim()))
      .filter((id) => Number.isFinite(id));
    await api.admin.bindGenres(bindMovieId.value, { genre_ids: ids });
    message.value = "Genres bound";
    bindMovieId.value = "";
    bindGenres.value = "";
  } catch (err) {
    message.value = err.message;
  }
}

async function createGenre() {
  message.value = "";
  try {
    await api.admin.createGenre({ name: genreName.value });
    message.value = "Genre created";
    genreName.value = "";
  } catch (err) {
    message.value = err.message;
  }
}

async function updateGenre() {
  message.value = "";
  try {
    await api.admin.updateGenre(genreId.value, { name: genreUpdate.value });
    message.value = "Genre updated";
    genreId.value = "";
    genreUpdate.value = "";
  } catch (err) {
    message.value = err.message;
  }
}

async function updatePolicy() {
  message.value = "";
  try {
    await api.admin.setRatingPolicy({
      min_score: Number(policyMin.value),
      max_score: Number(policyMax.value),
      step: Number(policyStep.value),
      allow_update: true
    });
    message.value = "Policy updated";
  } catch (err) {
    message.value = err.message;
  }
}

async function generate() {
  message.value = "";
  try {
    await api.admin.generateBatch({ algorithm: algo.value, top_n: Number(topN.value) });
    message.value = "Batch generated";
  } catch (err) {
    message.value = err.message;
  }
}

async function loadUsers() {
  message.value = "";
  try {
    users.value = await api.admin.listUsers(userQuery.value || "");
  } catch (err) {
    message.value = err.message;
  }
}

async function toggleUser(user) {
  message.value = "";
  try {
    const nextStatus = user.status === "active" ? "banned" : "active";
    await api.admin.setUserStatus(user.user_id, nextStatus);
    user.status = nextStatus;
  } catch (err) {
    message.value = err.message;
  }
}

async function updateReviewStatus() {
  message.value = "";
  try {
    await api.admin.setReviewStatus(reviewId.value, reviewStatus.value);
    message.value = "Review status updated";
    reviewId.value = "";
  } catch (err) {
    message.value = err.message;
  }
}
</script>
