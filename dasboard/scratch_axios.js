const axios = require('axios');
const API = axios.create({ baseURL: 'http://localhost:8011/api' });
console.log(API.getUri({ url: 'calendar/1' }));
