db.bluesky.aggregate([ { $group: { _id: "$commit.collection", count: { $sum: 1 } } }, { $sort: { count: -1 } } ]);
db.bluesky.aggregate([ { $match: { "kind": "commit", "commit.operation": "create" } }, { $group: { _id: "$commit.collection", count: { $sum: 1 }, users: { $addToSet: "$did" } } }, { $project: { event: "$_id", count: 1, users: { $size: "$users" } } }, { $sort: { count: -1 } } ]);
db.bluesky.aggregate([ { $match: { "kind": "commit", "commit.operation": "create", "commit.collection": { $in: ["app.bsky.feed.post", "app.bsky.feed.repost", "app.bsky.feed.like"] } } }, { $project: { _id: 0, event: "$commit.collection", hour_of_day: { $hour: { $toDate: { $divide: ["$time_us", 1000] } } } } }, { $group: { _id: { event: "$event", hour_of_day: "$hour_of_day" }, count: { $sum: 1 } } }, { $sort: { "_id.hour_of_day": 1, "_id.event": 1 } } ]);
db.bluesky.aggregate([ { $match: { "kind": "commit", "commit.operation": "create", "commit.collection": "app.bsky.feed.post" } }, { $project: { _id: 0, user_id: "$did", timestamp: { $toDate: { $divide: ["$time_us", 1000] } } } }, { $group: { _id: "$user_id", first_post_ts: { $min: "$timestamp" } } }, { $sort: { first_post_ts: 1 } }, { $limit: 3 } ]);
db.bluesky.aggregate([ { $match: { "kind": "commit", "commit.operation": "create", "commit.collection": "app.bsky.feed.post" } }, { $project: { _id: 0, user_id: "$did", timestamp: { $toDate: { $divide: ["$time_us", 1000] } } } }, { $group: { _id: "$user_id", min_timestamp: { $min: "$timestamp" }, max_timestamp: { $max: "$timestamp" } } }, { $project: { activity_span: { $dateDiff: { startDate: "$min_timestamp", endDate: "$max_timestamp", unit: "millisecond" } } } }, { $sort: { activity_span: -1 } }, { $limit: 3 } ]);