------------------------------------------------------------------------------------------------------------------------
-- {TABLE} is READ_JSONL('<directory>/*.jsonl', ignore_errors => true): the NDJSON files are queried in place,
-- with no load step. ignore_errors skips the few records in the dump that are not valid JSON.
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Q1 - Top event types
------------------------------------------------------------------------------------------------------------------------
SELECT commit ->> 'collection' AS event,
       COUNT(*) AS count
FROM {TABLE}
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q2 - Top event types together with unique users per event type
------------------------------------------------------------------------------------------------------------------------
SELECT commit ->> 'collection' AS event,
       COUNT(*) AS count,
       COUNT(DISTINCT did) AS users
FROM {TABLE}
WHERE kind = 'commit'
  AND commit ->> 'operation' = 'create'
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q3 - When do people use BlueSky
------------------------------------------------------------------------------------------------------------------------
SELECT commit ->> 'collection' AS event,
       EXTRACT(HOUR FROM CAST(time_us AS TIMESTAMP[us])) AS hour_of_day,
       COUNT(*) AS count
FROM {TABLE}
WHERE kind = 'commit'
  AND commit ->> 'operation' = 'create'
  AND commit ->> 'collection' IN ('app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like')
GROUP BY event, hour_of_day
ORDER BY hour_of_day, event;

------------------------------------------------------------------------------------------------------------------------
-- Q4 - top 3 post veterans
------------------------------------------------------------------------------------------------------------------------
SELECT did AS user_id,
       CAST(MIN(time_us) AS TIMESTAMP[us]) AS first_post_ts
FROM {TABLE}
WHERE kind = 'commit'
  AND commit ->> 'operation' = 'create'
  AND commit ->> 'collection' = 'app.bsky.feed.post'
GROUP BY user_id
ORDER BY first_post_ts ASC
LIMIT 3;

------------------------------------------------------------------------------------------------------------------------
-- Q5 - top 3 users with longest activity
------------------------------------------------------------------------------------------------------------------------
SELECT did AS user_id,
       CAST((MAX(time_us) - MIN(time_us)) / 1000 AS INTEGER) AS activity_span
FROM {TABLE}
WHERE kind = 'commit'
  AND commit ->> 'operation' = 'create'
  AND commit ->> 'collection' = 'app.bsky.feed.post'
GROUP BY user_id
ORDER BY activity_span DESC
LIMIT 3;
