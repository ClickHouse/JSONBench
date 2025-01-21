------------------------------------------------------------------------------------------------------------------------
-- Q1 - Top event types
------------------------------------------------------------------------------------------------------------------------
SELECT
    j->>'$.commit.collection' AS event,
    count() AS count
FROM bluesky
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q2 - Top event types together with unique users per event type
------------------------------------------------------------------------------------------------------------------------

SELECT
    j->>'$.commit.collection' AS event,
    count() AS count,count(DISTINCT j->>'$.did') AS users
FROM bluesky
WHERE (j->>'$.kind' = 'commit')
  AND (j->>'$.commit.operation' = 'create')
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q3 - When do people use BlueSky
------------------------------------------------------------------------------------------------------------------------

SELECT
    j->>'$.commit.collection' AS event,
    hour(TO_TIMESTAMP(CAST(j->>'$.time_us' AS BIGINT) / 1000000)) as hour_of_day,
    count() AS count
FROM bluesky
WHERE (j->>'$.kind' = 'commit')
  AND (j->>'$.commit.operation' = 'create')
  AND (j->>'$.commit.collection' in ['app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like'])
GROUP BY event, hour_of_day
ORDER BY hour_of_day, event;

------------------------------------------------------------------------------------------------------------------------
-- Q4 - top 3 post veterans
------------------------------------------------------------------------------------------------------------------------

SELECT
    j->>'$.did'::String as user_id,
    TO_TIMESTAMP(CAST(MIN(j->>'$.time_us') AS BIGINT) / 1000000) AS first_post_date
FROM bluesky
WHERE (j->>'$.kind' = 'commit')
  AND (j->>'$.commit.operation' = 'create')
  AND (j->>'$.commit.collection' = 'app.bsky.feed.post')
GROUP BY user_id
ORDER BY first_post_date ASC
LIMIT 3;

------------------------------------------------------------------------------------------------------------------------
-- Q5 - top 3 users with longest activity
------------------------------------------------------------------------------------------------------------------------

SELECT
    j->>'$.did'::String as user_id,
    date_diff('milliseconds', TO_TIMESTAMP(CAST(MIN(j->>'$.time_us') AS BIGINT) / 1000000),
    TO_TIMESTAMP(CAST(MAX(j->>'$.time_us') AS BIGINT) / 1000000)) AS activity_span
FROM bluesky
WHERE (j->>'$.kind' = 'commit')
  AND (j->>'$.commit.operation' = 'create')
  AND (j->>'$.commit.collection' = 'app.bsky.feed.post')
GROUP BY user_id
ORDER BY activity_span DESC
LIMIT 3;