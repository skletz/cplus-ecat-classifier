#MySQL 5.7.12
#please drop objects you've created at the end of the script
#or check for their existance before creating
#'\\' is a delimiter

select version() as 'mysql version';

DROP TABLE IF EXISTS myTab;

CREATE TABLE IF NOT EXISTS myTab (
	id 			SERIAL PRIMARY KEY,		-- SERIAL alias for BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    timecode    decimal(7,2) not null,
	label		VARCHAR(512),
    video		VARCHAR(512),
    prediction    decimal(7,2) not null
) ENGINE=INNODB DEFAULT CHARSET=utf8;

INSERT INTO myTab
    (timecode, label, video, prediction)
VALUES
    ('0.0', 'smoke', 'video1', 0.2),
    ('0.0', 'no smoke', 'video1', 0.8),
    ('0.0333', 'smoke', 'video1', 0.3),
    ('0.0333', 'no smoke', 'video1', 0.7),
    ('0.0667', 'smoke', 'video1', 0.1),
    ('0.0667', 'no smoke', 'video1', 0.9),
    ('0.1', 'smoke', 'video1', 0.8),
    ('0.1', 'no smoke', 'video1', 0.2),
    ('0.1333', 'smoke', 'video2', 0.7),
    ('0.1333', 'no smoke', 'video2', 0.3),
    ('0.1667', 'smoke', 'video2', 0.6),
    ('0.1667', 'no smoke', 'video2', 0.4),
    ('0.2', 'smoke', 'video2', 0.8),
    ('0.2', 'no smoke', 'video2', 0.2);


/*ToDo:
  -----
    Average all rows with regarding prediction when the timecode is within a range of other timecodes.
*/


/*SELECT t.id, t.timecode, t.label, t.video
FROM  myTab AS t
WHERE
       ( SELECT b.timecode
         FROM myTab AS b
         WHERE t.label = b.label
           AND t.video = b.video
           AND b.timecode < t.timecode
         ORDER BY b.timecode DESC
         LIMIT 1
       )
 ;*/


SELECT t.video, t.label, t.timecode, t.prediction
FROM myTab AS t
WHERE (
    SELECT b.timecode
    FROM myTab AS b
    WHERE t.video = b.video
    AND b.timecode < t.timecode
    ORDER BY b.timecode DESC
    LIMIT 1
) + 0.01 <= t.timecode
OR
   t.timecode + 0.01 <=
   ( SELECT b.timecode
     FROM myTab AS b
     WHERE t.video = b.video
       AND t.timecode < b.timecode
     ORDER BY b.timecode ASC
     LIMIT 1
   )
