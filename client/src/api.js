import useAuth from "./store/auth.js";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:3000";

async function request(path, options = {}) {
  const { state, clearAuth } = useAuth();
  const headers = {
    "Content-Type": "application/json",
    ...(options.headers || {})
  };
  if (state.token) {
    headers.Authorization = `Bearer ${state.token}`;
  }
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers
  });
  if (res.status === 401) {
    clearAuth();
  }
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const message = data.error || "Request failed";
    throw new Error(message);
  }
  return data;
}

export const api = {
  register: (payload) => request("/api/auth/register", { method: "POST", body: JSON.stringify(payload) }),
  login: (payload) => request("/api/auth/login", { method: "POST", body: JSON.stringify(payload) }),
  listMovies: (params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return request(`/api/movies${qs ? `?${qs}` : ""}`);
  },
  getMovie: (id) => request(`/api/movies/${id}`),
  listGenres: () => request("/api/genres"),
  rateMovie: (payload) => request("/api/ratings", { method: "POST", body: JSON.stringify(payload) }),
  createReview: (payload) => request("/api/reviews", { method: "POST", body: JSON.stringify(payload) }),
  updateReview: (id, payload) => request(`/api/reviews/${id}`, { method: "PUT", body: JSON.stringify(payload) }),
  deleteReview: (id) => request(`/api/reviews/${id}`, { method: "DELETE" }),
  listRecommendations: (algorithm) => request(`/api/recommendations${algorithm ? `?algorithm=${algorithm}` : ""}`),
  startWatch: (payload) => request("/api/watch", { method: "POST", body: JSON.stringify(payload) }),
  listWatchHistory: () => request("/api/watch/history"),
  admin: {
    createMovie: (payload) => request("/api/movies", { method: "POST", body: JSON.stringify(payload) }),
    updateMovie: (id, payload) => request(`/api/movies/${id}`, { method: "PUT", body: JSON.stringify(payload) }),
    bindGenres: (id, payload) => request(`/api/movies/${id}/genres`, { method: "PUT", body: JSON.stringify(payload) }),
    createGenre: (payload) => request("/api/genres", { method: "POST", body: JSON.stringify(payload) }),
    updateGenre: (id, payload) => request(`/api/genres/${id}`, { method: "PUT", body: JSON.stringify(payload) }),
    listUsers: (q) => request(`/api/admin/users${q ? `?q=${encodeURIComponent(q)}` : ""}`),
    setUserStatus: (id, status) => request(`/api/admin/users/${id}/status`, { method: "PUT", body: JSON.stringify({ status }) }),
    setReviewStatus: (id, status) => request(`/api/reviews/${id}/status`, { method: "PUT", body: JSON.stringify({ status }) }),
    setRatingPolicy: (payload) => request("/api/admin/rating-policy", { method: "POST", body: JSON.stringify(payload) }),
    generateBatch: (payload) => request("/api/admin/recommendations/generate", { method: "POST", body: JSON.stringify(payload) })
  }
};
