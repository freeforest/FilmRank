<template>
  <section class="page auth-page">
    <div class="card auth-card">
      <h1>Create your account</h1>
      <p class="muted">Join FilmRank to rate movies and build your profile.</p>
      <div class="form-stack">
        <input v-model="username" class="input" placeholder="Username" />
        <input v-model="email" class="input" placeholder="Email" />
        <input v-model="password" class="input" type="password" placeholder="Password" />
        <button class="button" @click="submit">Create account</button>
      </div>
      <p class="muted" v-if="message">{{ message }}</p>
      <RouterLink class="link" to="/login">Already registered? Login</RouterLink>
    </div>
  </section>
</template>

<script setup>
import { ref } from "vue";
import { RouterLink } from "vue-router";
import { api } from "../api.js";

const username = ref("");
const email = ref("");
const password = ref("");
const message = ref("");

async function submit() {
  message.value = "";
  try {
    await api.register({ username: username.value, email: email.value, password: password.value });
    message.value = "Registered. Please login.";
  } catch (err) {
    message.value = err.message;
  }
}
</script>
