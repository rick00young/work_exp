### Redis: Delete all keys LIKE
```
DELETE FROM users WHERE email LIKE '%@spam-domain.biz'


redis-cli KEYS "users.email.*@spam-domain.biz" | xargs redis-cli DEL

```