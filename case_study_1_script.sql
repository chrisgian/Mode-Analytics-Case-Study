
/* checking for unique locations to join latter! */

SELECT
  user_id,
  count(*)
  FROM
    (SELECT location, user_id, count(*)
      FROM tutorial.yammer_events
      GROUP BY location, user_id) AS data
  GROUP BY user_id
  HAVING count(*) = 1


  /* getting change pre and post dates where values are proportions */

SELECT data.event_type, data.event_name, data.pre, data.post, data.post-data.pre as delta

FROM
  (SELECT
    event_type,
    event_name,
  ((sum(CASE WHEN  occurred_at > '2014-07-28'::date THEN 1 else 0 END)::float)/(SELECT count(*) FROM tutorial.yammer_events WHERE occurred_at > '2014-07-28'::date)::float*100)::decimal(5,2) AS post,
  ((sum(CASE WHEN  occurred_at < '2014-07-28'::date THEN 1 else 0 END)::float)/(SELECT count(*) FROM tutorial.yammer_events WHERE occurred_at < '2014-07-28'::date)::float*100)::decimal(5,2) AS pre
  FROM tutorial.yammer_events
  GROUP BY event_type, event_name
  ORDER BY 3 DESC) AS data

ORDER BY 4 DESC


/* getting change pre and post dates where values are proportions */


SELECT data.event_type, data.pre, data.post, data.post-data.pre as delta

FROM
  (SELECT
    event_type,
  ((sum(CASE WHEN  occurred_at > '2014-07-28'::date THEN 1 else 0 END)::float)/(SELECT count(*) FROM tutorial.yammer_events WHERE occurred_at > '2014-07-28'::date)::float*100)::decimal(5,2) AS post,
  ((sum(CASE WHEN  occurred_at < '2014-07-28'::date THEN 1 else 0 END)::float)/(SELECT count(*) FROM tutorial.yammer_events WHERE occurred_at < '2014-07-28'::date)::float*100)::decimal(5,2) AS pre
  FROM tutorial.yammer_events
  GROUP BY event_type
  ORDER BY 3 DESC) AS data

ORDER BY 4 DESC

/*exploring email trends by month */


SELECT
  action,
  left(occurred_at::char(4),4) AS year,
  substr(occurred_at::char(10),6,2) AS month,
  count(*)

FROM tutorial.yammer_emails
GROUP BY year, month, action
ORDER BY year, month

/*engagement freqneuncy by location for mont 7 and 8 */


SELECT
  left(occurred_at::char(4),4) AS year,
  substr(occurred_at::char(10),6,2) AS month,
  event_name,
  location,
  count(*)

FROM tutorial.yammer_events
WHERE event_type = 'engagement' AND event_name = 'login' AND (substr(occurred_at::char(10),6,2) IN ('07', '08'))
GROUP BY event_name, event_type, location, year, month
ORDER BY location, event_name, year, month

/* net change by count: developed nations lost the most engagement*/

SELECT
  *,
  aug_indicator - july_indicator AS net
FROM
  (SELECT
   event_name,
   event_type,
   location,
   SUM(CASE WHEN substr(occurred_at::char(10),6,2) = '07'  THEN 1 ELSE 0 END) AS july_indicator,
   SUM(CASE WHEN substr(occurred_at::char(10),6,2) = '08'  THEN 1 ELSE 0 END) AS aug_indicator
  FROM tutorial.yammer_events
  WHERE event_type = 'engagement'
  GROUP BY event_name, event_type, location) AS data
  ORDER BY net DESC

  SELECT
  data.location,
  sum(aug_indicator - july_indicator) AS engagement_sum
FROM
  (SELECT
   event_name,
   event_type,
   location,
   SUM(CASE WHEN substr(occurred_at::char(10),6,2) = '07'  THEN 1 ELSE 0 END) AS july_indicator,
   SUM(CASE WHEN substr(occurred_at::char(10),6,2) = '08'  THEN 1 ELSE 0 END) AS aug_indicator
  FROM tutorial.yammer_events
  WHERE event_type = 'engagement'
  GROUP BY event_name, event_type, location) AS data
  GROUP BY data.location
  ORDER BY engagement_sum DESC



/* CREATE A UNIQUE LOCATION TABLE TO JOIN EMAIL*/
SELECT
  *,
  data_aggregated.post-data_aggregated.pre as net
  FROM
    (SELECT
      location,
      action,
      SUM(case when data_w_locate.occurred_at < '2014-07-28'::date THEN 1 ELSE 0 END) AS pre,
      SUM(case when data_w_locate.occurred_at > '2014-07-28'::date THEN 1 ELSE 0 END) AS post


    FROM
      (SELECT
          *

        FROM tutorial.yammer_emails AS data_email
        JOIN
          (SELECT user_id,location FROM tutorial.yammer_events GROUP BY user_id, location) AS data_locate
        ON data_email.user_id = data_locate.user_id) AS data_w_locate
        GROUP BY location, action) as data_aggregated
  WHERE data_aggregated.action = 'sent_reengagement_email'
  ORDER BY NET DESC
