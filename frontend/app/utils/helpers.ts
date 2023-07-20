import axios from 'axios'

export const apiVoyagerClient = axios.create({
  baseURL: 'https://goerli-2.voyager.online/api',
  timeout: 10000,
  headers: {
    accept: 'application/json',
    'Content-type': 'application/json',
    'Cache-Control': 'no-cache',
  },
})