<template>
  <section v-if="movie" class="page">
    <div class="detail-hero">
      <div class="poster large" :style="posterStyle(movie)"></div>
      <div class="detail-info">
        <p class="eyebrow">Movie detail</p>
        <h1>{{ movie.title }}</h1>
        <p class="muted">{{ movie.description || "No description available." }}</p>

        <div class="tag-row">
          <span class="tag" v-for="genre in genres" :key="genre.genre_id">{{ genre.name }}</span>
        </div>

        <div class="detail-meta">
          <div>
            <p class="label">Original title</p>
            <p>{{ movie.original_title || "--" }}</p>
          </div>
          <div>
            <p class="label">Release</p>
            <p>{{ movie.release_date || "--" }}</p>
          </div>
          <div>
            <p class="label">Runtime</p>
            <p>{{ movie.runtime_minutes || "--" }} min</p>
          </div>
          <div>
            <p class="label">Language</p>
            <p>{{ movie.language || "--" }}</p>
          </div>
        </div>

        <div class="rating-strip">
          <div>
            <p class="label">Average score</p>
            <p class="score">{{ rating.avg_score ? Number(rating.avg_score).toFixed(1) : "--" }}</p>
          </div>
          <div>
            <p class="label">Ratings</p>
            <p class="score">{{ rating.rating_count || 0 }}</p>
          </div>
          <button class="button secondary" :disabled="!isAuthed" @click="startWatch">Start watching</button>
        </div>
        <p class="muted" v-if="watchMessage">{{ watchMessage }}</p>
      </div>
    </div>

    <div class="split">
      <div class="card">
        <h3>Rate this movie</h3>
        <p class="muted">Choose a score between 0 and 10.</p>
        <div class="range-row">
          <input v-model.number="score" type="range" min="0" max="10" step="0.5" />
          <span class="score-pill">{{ score.toFixed(1) }}</span>
        </div>
        <button class="button" :disabled="!isAuthed" @click="submitRating">Submit rating</button>
        <p class="muted" v-if="ratingMessage">{{ ratingMessage }}</p>
      </div>

      <div class="card">
        <h3>Write a review</h3>
        <textarea v-model="review" class="input" rows="4" placeholder="Share your thoughts..."></textarea>
        <button class="button" style="margin-top: 8px;" :disabled="!isAuthed" @click="submitReview">Post</button>
        <p class="muted" v-if="reviewMessage">{{ reviewMessage }}</p>
      </div>
    </div>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Latest reviews</h2>
        <span class="muted">{{ reviews.length }} comments</span>
      </div>
      <div v-if="reviews.length" class="stack">
        <div class="card review-card" v-for="item in reviews" :key="item.review_id">
          <div class="review-head">
            <strong>{{ item.username }}</strong>
            <span class="muted">{{ formatDate(item.created_at) }}</span>
          </div>
          <p v-if="editingReviewId !== item.review_id">{{ item.content }}</p>
          <div v-else>
            <textarea v-model="editingContent" class="input" rows="3"></textarea>
          </div>
          <div class="review-actions" v-if="isOwnReview(item)">
            <button
              v-if="editingReviewId !== item.review_id"
              class="button ghost"
              @click="startEdit(item)"
            >
              Edit
            </button>
            <button
              v-if="editingReviewId === item.review_id"
              class="button"
              @click="saveEdit(item)"
            >
              Save
            </button>
            <button
              v-if="editingReviewId === item.review_id"
              class="button secondary"
              @click="cancelEdit"
            >
              Cancel
            </button>
            <button class="button secondary" @click="removeReview(item)">Delete</button>
          </div>
        </div>
      </div>
      <p v-else class="muted">No reviews yet. Be the first to comment.</p>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Related recommendations</h2>
        <RouterLink class="link" to="/recommendations">See more</RouterLink>
      </div>
      <div class="grid" v-if="related.length">
        <article class="movie-card" v-for="item in related" :key="item.movie_id">
          <div class="poster" :style="posterStyle(item)"></div>
          <div class="card-body">
            <div>
              <h3>{{ item.title }}</h3>
              <p class="muted">{{ item.year || "-" }} / {{ item.language || "-" }}</p>
            </div>
            <RouterLink class="button secondary" :to="`/movies/${item.movie_id}`">Details</RouterLink>
          </div>
        </article>
      </div>
      <p v-else class="muted">No related titles yet.</p>
    </section>
  </section>
  <p v-else class="muted">Loading...</p>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import { RouterLink, useRoute } from "vue-router";
import { api } from "../api.js";
import useAuth from "../store/auth.js";

const route = useRoute();
const { state, isAuthed } = useAuth();

const movie = ref(null);
const genres = ref([]);
const rating = ref({});
const reviews = ref([]);
const related = ref([]);
const score = ref(6.5);
const review = ref("");
const ratingMessage = ref("");
const reviewMessage = ref("");
const watchMessage = ref("");
const editingReviewId = ref(null);
const editingContent = ref("");

function posterStyle(item) {
  if (!item.poster_url) {
    return { backgroundImage: "linear-gradient(135deg, #f5d2b8, #f1b58f)" };
  }
  return { backgroundImage: `url(${item.poster_url})` };
}

function formatDate(value) {
  if (!value) return "--";
  const date = new Date(value);
  return date.toLocaleString();
}

function isOwnReview(item) {
  return state.user && item.username === state.user.username;
}

function startEdit(item) {
  editingReviewId.value = item.review_id;
  editingContent.value = item.content;
}

function cancelEdit() {
  editingReviewId.value = null;
  editingContent.value = "";
}

async function saveEdit(item) {
  try {
    await api.updateReview(item.review_id, { content: editingContent.value });
    cancelEdit();
    await load();
  } catch (err) {
    reviewMessage.value = err.message;
  }
}

async function removeReview(item) {
  reviewMessage.value = "";
  try {
    await api.deleteReview(item.review_id);
    await load();
  } catch (err) {
    reviewMessage.value = err.message;
  }
}

async function load() {
  const data = await api.getMovie(route.params.id);
  movie.value = data.movie;
  rating.value = data.rating || {};
  genres.value = data.genres || [];
  reviews.value = data.reviews || [];

  if (genres.value.length) {
    const sameGenre = await api.listMovies({ genre_id: genres.value[0].genre_id });
    related.value = (sameGenre || []).filter((item) => item.movie_id !== movie.value.movie_id).slice(0, 6);
  } else {
    related.value = [];
  }
}

async function submitRating() {
  ratingMessage.value = "";
  try {
    await api.rateMovie({ movie_id: movie.value.movie_id, score: Number(score.value) });
    ratingMessage.value = "Rating saved";
    await load();
  } catch (err) {
    ratingMessage.value = err.message;
  }
}

async function submitReview() {
  reviewMessage.value = "";
  try {
    await api.createReview({ movie_id: movie.value.movie_id, content: review.value });
    reviewMessage.value = "Review posted";
    review.value = "";
    await load();
  } catch (err) {
    reviewMessage.value = err.message;
  }
}

async function startWatch() {
  watchMessage.value = "";
  if (!isAuthed.value) {
    watchMessage.value = "Login required to start watching.";
    return;
  }
  try {
    await api.startWatch({ movie_id: movie.value.movie_id, device: "web" });
    watchMessage.value = "Watch session started.";
  } catch (err) {
    watchMessage.value = err.message;
  }
}

onMounted(load);
watch(() => route.params.id, () => {
  load();
});
</script>

