USE bank;

SELECT * 
FROM bankdata;

SELECT AVG(age), AVG(balance), AVG(duration)
FROM bankdata;

SELECT AVG(age), AVG(balance), AVG(duration)
FROM bankdata
WHERE y = "yes";

SELECT (COUNT(CASE WHEN y = "yes" THEN 1 END) * 100) / (SELECT COUNT(*) FROM bankdata WHERE y = "yes") AS successRate,
	CASE
		WHEN age < 30 THEN "Young"
        WHEN age > 30 AND age < 50 THEN "Middle Aged"
        ELSE "Senior"
	END AS ageGroup
FROM bankdata
GROUP BY ageGroup;
        
SELECT `month`, COUNT(CASE WHEN y = "yes" THEN 1 END) / COUNT(*) AS successRate
FROM bankdata
GROUP BY `month`
ORDER BY successRate DESC;

SELECT education, COUNT(CASE WHEN y = "yes" THEN 1 END) / (SELECT COUNT(*) FROM bankdata WHERE y = "yes") AS successRate
FROM bankdata
GROUP BY education
ORDER BY successRate DESC;

WITH stats AS 
	(SELECT ROUND(AVG(duration), 2) AS avgDuration,
    ROUND(STDDEV(duration), 2) AS stdDuration
    FROM bankdata)
SELECT age, job, duration
FROM bankdata
WHERE duration > (SELECT avgDuration + 2 * stdDuration FROM stats)
OR duration < (SELECT avgDuration - 2 * stdDuration FROM stats)
ORDER BY duration DESC;
		

WITH calculation AS 
	(SELECT ROUND(SUM((age - (SELECT AVG(age) FROM bankdata)) * (duration - (SELECT AVG(duration) FROM bankdata))), 3) AS numerator,
	ROUND(SQRT(SUM(POWER(age - (SELECT AVG(age) FROM bankdata), 2)) * SUM(POWER(duration - (SELECT AVG(duration) FROM bankdata), 2))), 3) as denominator
	FROM bankdata)
SELECT ROUND(numerator / denominator, 5) AS r
FROM calculation;


SELECT `default`, loan, housing
FROM bankdata
WHERE `default` = "yes"











