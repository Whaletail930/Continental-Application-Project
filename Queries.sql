use Continental

SELECT images.record_file_name, images.timestamp, images.image_format, images.image_path, images.country
FROM images
LEFT JOIN labels ON images.record_file_name = labels.record_file_name AND images.timestamp = labels.timestamp
WHERE labels.record_file_name IS NULL;


SELECT img.record_file_name, img.timestamp, lbl.label_type, lbl.label_size
FROM images img
JOIN labels lbl ON img.record_file_name = lbl.record_file_name AND img.timestamp = lbl.timestamp
LEFT JOIN labels lbl2 ON img.record_file_name = lbl2.record_file_name AND img.timestamp = lbl2.timestamp AND lbl2.label_size > lbl.label_size
GROUP BY img.record_file_name, img.timestamp, lbl.label_type, lbl.label_size
HAVING COUNT(DISTINCT lbl2.label_size) < 2 OR lbl.label_size = MAX(lbl2.label_size);



WITH LabelCounts AS (
    SELECT img.record_file_name, img.timestamp, COUNT(*) AS label_count
    FROM images img
    JOIN labels lbl ON img.record_file_name = lbl.record_file_name AND img.timestamp = lbl.timestamp
    WHERE lbl.label_size >= 0.6
    GROUP BY img.record_file_name, img.timestamp
)
SELECT img.record_file_name, img.timestamp, img.image_format, img.image_path, img.country
FROM images img
JOIN LabelCounts lc ON img.record_file_name = lc.record_file_name AND img.timestamp = lc.timestamp
WHERE lc.label_count = (
    SELECT MAX(label_count)
    FROM LabelCounts
);

