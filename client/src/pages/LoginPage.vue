<template>
  <section class="page auth-page">
    <div class="card auth-card">
      <h1>Welcome back</h1>
      <p class="muted">Log in to access recommendations and your profile.</p>
      <div class="form-stack">
        <input v-model="username" class="input" placeholder="Username" />
        <input v-model="password" class="input" type="password" placeholder="Password" />
        <button class="button" @click="submit">Login</button>
      </div>
      <p class="muted" v-if="message">{{ message }}</p>
      <RouterLink class="link" to="/register">Need an account? Register</RouterLink>
    </div>
  </section>
</template>

<script setup>
import { ref } from "vue";
import { useRouter, RouterLink } from "vue-router";
import { api } from "../api.js";
import useAuth from "../store/auth.js";

const router = useRouter();
const { setAuth } = useAuth();

const username = ref("");
const password = ref("");
const message = ref("");

async function submit() {
  message.value = "";
  try {
    const data = await api.login({ username: username.value, password: password.value });
    setAuth(data.token, data.user);
    router.push("/");
  } catch (err) {
    message.value = err.message;
  }
}
</script>
