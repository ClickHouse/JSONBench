------------------------------------------------------------------------------------------------------------------------
-- Q1 - Top event types
------------------------------------------------------------------------------------------------------------------------
SELECT
    json_get_string(data, '$.commit.collection') AS event, count() AS count
FROM bluesky
GROUP BY event
ORDER BY cnt DESC

------------------------------------------------------------------------------------------------------------------------
-- Q2 - Top event types together with unique users per event type
------------------------------------------------------------------------------------------------------------------------
SELECT
    json_get_string(data, '$.commit.collection') AS event,
    count() AS cnt,
    count(DISTINCT json_get_string(data, '$.did')) AS users
FROM bluesky
WHERE
    (json_get_string(data, '$.kind') = 'commit') AND
    (json_get_string(data, '$.commit.operation') = 'create')
GROUP BY event
ORDER BY cnt DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q3 - When do people use BlueSky
------------------------------------------------------------------------------------------------------------------------
SELECT
    json_get_string(data, '$.commit.collection') AS event,
    date_part('hour', to_timestamp_micros(json_get_int(data, '$.time_us'))) as hour_of_day,
    count() AS cnt
FROM bluesky
WHERE
    (json_get_string(data, '$.kind') = 'commit') AND
    (json_get_string(data, '$.commit.operation') = 'create') AND
    json_get_string(data, '$.commit.collection') IN ('app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like')
GROUP BY event,
         hour_of_day
ORDER BY hour_of_day,
         event;

------------------------------------------------------------------------------------------------------------------------
-- Q4 - top 3 post veterans
------------------------------------------------------------------------------------------------------------------------
SELECT
    json_get_string(data, '$.did') as user_id,
    min(to_timestamp_micros(json_get_int(data, '$.time_us'))) AS first_post_ts
FROM bluesky
WHERE
    (json_get_string(data, '$.kind') = 'commit') AND
    (json_get_string(data, '$.commit.operation') = 'create') AND
    (json_get_string(data, '$.commit.collection') = 'app.bsky.feed.post')
GROUP BY user_id
ORDER BY first_post_ts ASC LIMIT 3;

------------------------------------------------------------------------------------------------------------------------
-- Q5 - top 3 users with longest activity
------------------------------------------------------------------------------------------------------------------------
SELECT
    json_get_string(data, '$.did') as user_id,
    date_part(
        'epoch',
        max(to_timestamp_micros(json_get_int(data, '$.time_us'))) -
        min(to_timestamp_micros(json_get_int(data, '$.time_us')))
    ) AS activity_span
FROM bluesky
WHERE
    (json_get_string(data, '$.kind') = 'commit') AND
    (json_get_string(data, '$.commit.operation') = 'create') AND
    (json_get_string(data, '$.commit.collection') = 'app.bsky.feed.post')
GROUP BY user_id
ORDER BY activity_span DESC LIMIT 3;
