------------------------------------------------------------------------------------------------------------------------
-- Q1 - Top event types
------------------------------------------------------------------------------------------------------------------------

SELECT get_json_string(data, 'commit.collection') AS event,
       count() AS count 
FROM bluesky 
GROUP BY event 
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q2 - Top event types together with unique users per event type
------------------------------------------------------------------------------------------------------------------------
SELECT
    get_json_string(data, 'commit.collection') AS event,
    count() AS count,
	  count(DISTINCT get_json_string(data, 'did')) AS users
FROM bluesky
WHERE (get_json_string(data, 'kind') = 'commit')
  AND (get_json_string(data, 'commit.operation') = 'create') 
GROUP BY event
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------
-- Q3 - When do people use BlueSky
------------------------------------------------------------------------------------------------------------------------
SELECT
    get_json_string(data, 'commit.collection') AS event, 
    hour(from_unixtime(round(divide(get_json_int(data, 'time_us'), 1000000)))) as hour_of_day,
    count() AS count
FROM bluesky
WHERE (get_json_string(data, 'kind') = 'commit') 
AND (get_json_string(data, 'commit.operation') = 'create') 
AND (array_contains(['app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like'], get_json_string(data, 'commit.collection'))) 
GROUP BY event, hour_of_day
ORDER BY hour_of_day, event;

------------------------------------------------------------------------------------------------------------------------
-- Q4 - top 3 post veterans
------------------------------------------------------------------------------------------------------------------------
SELECT
      get_json_string(data, '$.did') as user_id, 
      min(from_unixtime(round(divide(get_json_int(data, 'time_us'), 1000000)))) AS first_post_date 
FROM bluesky
WHERE (get_json_string(data, 'kind') = 'commit') 
  AND (get_json_string(data, 'commit.operation') = 'create') 
  AND (get_json_string(data, 'commit.collection') = 'app.bsky.feed.post')
GROUP BY user_id
ORDER BY first_post_date ASC
LIMIT 3;

------------------------------------------------------------------------------------------------------------------------
-- Q5 - top 3 users with longest activity
------------------------------------------------------------------------------------------------------------------------
SELECT
      get_json_string(data, '$.did') as user_id, 
      date_diff('millisecond', 
      min(from_unixtime(round(divide(get_json_int(data, 'time_us'), 1000000)))),
      max(from_unixtime(round(divide(get_json_int(data, 'time_us'), 1000000))))) AS activity_span 
FROM bluesky
WHERE (get_json_string(data, 'kind') = 'commit') 
  AND (get_json_string(data, 'commit.operation') = 'create') 
  AND (get_json_string(data, 'commit.collection') = 'app.bsky.feed.post')
GROUP BY user_id
ORDER BY activity_span DESC
LIMIT 3;
