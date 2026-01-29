import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ||'https://callto-4.onrender.com/api'||  'http://localhost:3001/api',
});

// Request interceptor to add Authorization header
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid, redirect to login
      localStorage.removeItem('adminToken');
      window.location.href = '/admin/login';
    }
    return Promise.reject(error);
  }
);

// User methods
export const getUsers = () => api.get('/users');
export const getUserById = (user_id) => api.get(`/users/${user_id}`);
export const updateUser = (user_id, payload) => api.put(`/users/${user_id}`, payload);
export const deleteUser = (user_id) => api.delete(`/users/${user_id}`);

// Listener methods
export const getListeners = () => api.get('/listeners');
export const getListenerById = (listener_id) => api.get(`/listeners/${listener_id}`);
export const updateListener = (listener_id, payload) => api.put(`/listeners/${listener_id}`, payload);
export const deleteListener = (listener_id) => api.delete(`/listeners/${listener_id}`);

// Admin methods
export const getAdminListeners = () => api.get('/admin/listeners');

export default api;