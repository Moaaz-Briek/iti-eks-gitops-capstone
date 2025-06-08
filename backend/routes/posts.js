var express = require('express');
var router = express.Router();
const Post = require('../models/post');
const redis = require('../db/redis');
const { client, register } = require('../metrics');

const totalRequests = new client.Counter({
  name: 'posts_api_requests_total',
  help: 'Total number of requests to /posts',
  labelNames: ['method', 'route'],
  registers: [register],
});

const successfulResponses = new client.Counter({
  name: 'posts_api_success_total',
  help: 'Total number of successful responses from /posts',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const failedResponses = new client.Counter({
  name: 'posts_api_failures_total',
  help: 'Total number of failed responses from /posts',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});


router.get('/', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/' });
  try {
    redis.get('posts', async (err, cachedPosts) => {
      if (err) {
        console.error('Error checking Redis:', err);
        return res.status(500).json({ error: 'Error accessing cache' });
      }

      if (cachedPosts) {
        successfulResponses.inc({ method: req.method, route: '/', status: 200 });
        console.log('Returning posts from cache');
        return res.status(200).json({ data: JSON.parse(cachedPosts) });
      }

      console.log('Cache miss, fetching from database');
      const posts = await Post.findAll();
      redis.setex('posts', 3600, JSON.stringify(posts));  // Cache data for 1 hour

      successfulResponses.inc({ method: req.method, route: '/', status: 200 });
      console.log('Returning posts from database');
      return res.status(200).json({ data: posts });
    });
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/', status: 500 });
    console.error('Error retrieving posts:', error);
    res.status(500).json({ error: 'Error retrieving posts' });
  }
});

router.post('/', async (req, res) => {
  const { title, description } = req.body;
  totalRequests.inc({ method: req.method, route: '/' });
  try {
    const newPost = await Post.create({ title, description });
    successfulResponses.inc({ method: req.method, route: '/', status: 200 });
    console.log('Post created successfully:', newPost);
    redis.del(`posts`, (delErr, response) => {
      if (delErr) {
        console.error('Error deleting cached posts:', delErr);
      } else if (response === 1) {
        console.log(`Cache for posts deleted successfully.`);
      }
    });

    res.status(201).json(newPost);
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/', status: 500 });
    console.error('Error creating post:', error);
    res.status(400).json({ error: 'Error creating post' });
  }
});


router.get('/:id', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/:id' });
  const { id } = req.params;
  try {
    redis.get(`post:${id}`, async (err, cachedPost) => {
      if (err) {
        console.error('Error checking Redis:', err);
        return res.status(500).json({ error: 'Error accessing cache' });
      }

      if (cachedPost) {
        successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
        console.log('Returning post from cache');
        return res.status(200).json(JSON.parse(cachedPost));
      }

      console.log('Cache miss, fetching from database');
      const post = await Post.findByPk(id);
      if (post) {
        redis.setex(`post:${id}`, 3600, JSON.stringify(post));  // Cache data for 1 hour
        successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
        console.log('Returning post from database');
        return res.status(200).json(post);
      } else {
        failedResponses.inc({ method: req.method, route: '/:id', status: 404 });
        console.log('Post not found');
        return res.status(404).json({ error: 'Post not found' });
      }
    });
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/:id', status: 500 });
    console.error('Error retrieving post:', error);
    res.status(500).json({ error: 'Error retrieving post' });
  }
});

router.put('/:id', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/:id' });
  const { id } = req.params;
  const { title, description } = req.body;
  try {
    const post = await Post.findByPk(id);
    if (post) {
      redis.get(`post:${id}`, (err, cachedPost) => {
        if (err) {
          console.error('Error checking Redis:', err);
        } else if (cachedPost) {
          redis.del(`post:${id}`, (delErr, response) => {
            if (delErr) {
              console.error('Error deleting cached post:', delErr);
            } else if (response === 1) {
              console.log(`Cache for post:${id} deleted successfully.`);
            }
          });
        } else {
          console.log(`Post ${id} not found in cache, skipping cache deletion.`);
        }
      });
      post.title = title || post.title;
      post.description = description || post.description;
      await post.save();
      successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
      console.log('Post updated successfully:', post);

      redis.del(`posts`, (delErr, response) => {
        if (delErr) {
          console.error('Error deleting cached posts:', delErr);
        } else if (response === 1) {
          console.log(`Cache for posts deleted successfully.`);
        }
      });

      res.status(200).json(post);
    } else {
      failedResponses.inc({ method: req.method, route: '/:id', status: 404 });
      console.log('Post not found');
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/:id', status: 500 });
    console.error('Error updating post:', error);
    res.status(500).json({ error: 'Error updating post' });
  }
});

router.delete('/:id', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/:id' });
  const { id } = req.params;
  try {
    const post = await Post.findByPk(id);
    if (post) {
      await post.destroy();
      redis.get(`post:${id}`, (err, cachedPost) => {
        if (err) {
          console.error('Error checking Redis:', err);
        } else if (cachedPost) {
          redis.del(`post:${id}`, (delErr, response) => {
            if (delErr) {
              console.error('Error deleting cached post:', delErr);
            } else if (response === 1) {
              console.log(`Cache for post:${id} deleted successfully.`);
            }
          });
        } else {
          console.log(`Post ${id} not found in cache, skipping cache deletion.`);
        }
      });
      successfulResponses.inc({ method: req.method, route: '/:id', status: 200 });
      console.log('Post deleted successfully:', post);

      redis.del(`posts`, (delErr, response) => {
        if (delErr) {
          console.error('Error deleting cached posts:', delErr);
        } else if (response === 1) {
          console.log(`Cache for posts deleted successfully.`);
        }
      });

      res.status(200).json({ message: 'Post deleted successfully' });
    } else {
      failedResponses.inc({ method: req.method, route: '/:id', status: 404 });
      console.log('Post not found');
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    console.error('Error deleting post:', error);
    failedResponses.inc({ method: req.method, route: '/:id', status: 500 });
    console.error('Error deleting post:', error);
    res.status(500).json({ error: 'Error deleting post' });
  }
});

module.exports = router;
