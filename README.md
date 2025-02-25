# Bank Marketing - SQL Analysis 🏦

## Context
This dataset comes from UC Irvine's data repository from [here.](https://archive.ics.uci.edu/dataset/222/bank+marketing) The data is collected from marketing campaign phone calls from a Portuguese banking institution. The original goal of the dataset was to help banks predict if clients will subscribe to a term deposit (Column Y).


### Dataset
---
There are four main categories of the dataset that encompass all the columns:

#### 1. Customer Demographics
- **Age**
- **Job Type**
- **Marital** (Single, married, divorced)
- **Education** 

#### 2. Financial Information
- **Balance** (Average Yearly Balance)
- **Housing** (Housing loan?)
- **Loan** (Personal Loan?)
- **Default** (Credit default?)

#### 3. Campaign Details
- **Contact**
- **Day**
- **Month**
- **Duration** (Call length)
- **Campaign** (# contacts made)
- **pdays** (# days since last call)
- **previous** (# contacts made previously)
- **poutcome** (Outcome of last campaign)

#### 4. Target Variable
- **y** (Client subscribed to term deposit?)

---

Term Deposit: An agreement where customers are paid interest on a deposited sum of money similar in principle to a treasury bond but done between a bank and an investor.

---

*First 4 rows of the dataset*

### Part 1: Demographics and Financial Information
| age | job           | marital  | education | default | balance | housing | loan |
|-----|---------------|----------|-----------|---------|---------|---------|------|
| 58  | management    | married  | tertiary  | no      | 2143    | yes     | no   |
| 44  | technician    | single   | secondary | no      | 29      | yes     | no   |
| 33  | entrepreneur  | married  | secondary | no      | 2       | yes     | yes  |
| 47  | blue-collar   | married  | unknown   | no      | 1506    | yes     | no   |

### Part 2: Campaign Details and Target Variable
| contact  | day | month | duration | campaign | pdays | previous | poutcome | y   |
|----------|-----|-------|----------|----------|-------|----------|----------|-----|
| unknown  | 5   | may   | 261      | 1        | -1    | 0        | unknown  | no  |
| unknown  | 5   | may   | 151      | 1        | -1    | 0        | unknown  | no  |
| unknown  | 5   | may   | 76       | 1        | -1    | 0        | unknown  | no  |
| unknown  | 5   | may   | 92       | 1        | -1    | 0        | unknown  | no  |

### Analysis 

```sql
SELECT AVG(age), AVG(balance), AVG(duration)
FROM bankdata
```
| AVG(age)  | AVG(balance) | AVG(duration) |
|-----------|--------------|---------------|
| 40.9362   | 1362.2721    | 258.1631      |

The average bank customer is middle aged with about 1362 euros (~1400$) in their account. Is there a correlation between these factors and term deposits?

```sql
SELECT AVG(age), AVG(balance), AVG(duration)
FROM bankdata
WHERE y = "yes";
```
| AVG(age)  | AVG(balance) | AVG(duration) |
|-----------|--------------|---------------|
| 41.6701   | 1804.2679    | 537.2946      |

The age of people who has term deposits seems similar to the average while balance is about 400 euro higher. However, the average call lasted about 4.7 minutes longer.

---

Using the group by clause, you can also check how often people are likely to subscribe to term deposits based on age groups.


```sql
SELECT (COUNT(CASE WHEN y = "yes" THEN 1 END) * 100) / (SELECT COUNT(*) FROM bankdata WHERE y = "yes") AS successRate,
	CASE
		WHEN age < 30 THEN "Young"
        WHEN age > 30 AND age < 50 THEN "Middle Aged"
        ELSE "Senior"
	END AS ageGroup
FROM bankdata
GROUP BY ageGroup
```

| successRate | ageGroup     |
|-------------|--------------|
| 30.2893     | Senior       |
| 52.1649     | Middle Aged  |
| 17.5458     | Young        |

It appears that middle-aged (30-50) are most likely to subscribe to a term deposit which makes sense since they would be favorable to low-risk investments. Banks would find better success in appealing to this age group.

---
The same process can be done to see if different months have varying success rates.

```sql
SELECT `month`, COUNT(CASE WHEN y = "yes" THEN 1 END) / COUNT(*) AS successRate
FROM bankdata
GROUP BY `month`
ORDER BY successRate DESC;
```

| month | successRate |
|-------|-------------|
| mar   | 0.5199      |
| dec   | 0.4673      |
| sep   | 0.4646      |
| oct   | 0.4377      |
| apr   | 0.1968      |
| feb   | 0.1665      |
| aug   | 0.1101      |
| jun   | 0.1022      |
| nov   | 0.1015      |
| jan   | 0.1012      |
| jul   | 0.0909      |
| may   | 0.0672      |


Next, we can also find the optimal education level of the client to maximize the chances of success.

```sql
SELECT education, COUNT(CASE WHEN y = "yes" THEN 1 END) / (SELECT COUNT(*) FROM bankdata WHERE y = "yes") AS successRate
FROM bankdata
GROUP BY education
ORDER BY successRate DESC
```

| education  | successRate |
|------------|-------------|
| secondary  | 0.4632      |
| tertiary   | 0.3774      |
| primary    | 0.1117      |
| unknown    | 0.0476      |

It is surprising that the tertiary education level (college) has a lower success rate than secondary (highschool). Normally we would have assumed higher education levels leads to more wealth to use on a term deposit.

---

We can find outliers in the call duration column by searching 2 standard deviations away from the mean. Now we can see if abnormally long calls have a significant effect on accepting term deposits.

```sql
WITH stats AS 
	(SELECT ROUND(AVG(duration), 2) AS avgDuration,
    ROUND(STDDEV(duration), 2) AS stdDuration
    FROM bankdata)
SELECT age, job, duration
FROM bankdata
WHERE duration > (SELECT avgDuration + 2 * stdDuration FROM stats)
OR duration < (SELECT avgDuration - 2 * stdDuration FROM stats)
ORDER BY duration DESC
```

| age | job             | duration |
|-----|-----------------|----------|
| 59  | technician      | 4918     |
| 59  | management      | 3881     |
| 45  | services        | 3785     |
| 37  | blue-collar     | 3422     |
| 45  | blue-collar     | 3366     |
| 43  | self-employed   | 3322     |
| 30  | admin.          | 3284     |



There could be a relationship between age and duration, the correlation coefficient would give better insight.

<img src="https://media.datacamp.com/legacy/v1717150757/image_4d74794084.png" alt="Pearson Correlation Coeffecient" width="300" height="100">

```sql
WITH calculation AS 
	(SELECT ROUND(SUM((age - (SELECT AVG(age) FROM   bankdata)) * (duration - (SELECT AVG(duration) FROM bankdata))), 3) AS numerator,
	ROUND(SQRT(SUM(POWER(age - (SELECT AVG(age) FROM bankdata), 2)) * SUM(POWER(duration - (SELECT AVG(duration) FROM bankdata), 2))), 3) as denominator
	FROM bankdata)

SELECT ROUND(numerator / denominator, 5) AS R
FROM calculation
```

| R |         
|----|
|-0.00465|     

This Pearson correlation number tells us that the dataset is a slight negative correlation between age and duration. This implies that calling an older customer might lead to a longer call duration than with a younger customer.

--- 

Finally, let's see if having debt influences the rate which customers subscribe to a term deposit.

```sql
SELECT COUNT(CASE WHEN y = "yes" THEN 1 END) / (SELECT COUNT(*) FROM bankdata WHERE y = "yes") AS SuccessRate,
CASE
	WHEN `default` = "yes" THEN "Credit Default"
	WHEN housing = "yes" THEN "Housing Loan"
	WHEN loan = "yes" THEN "Personal Loan"
    ELSE "No Loans"
END AS LoanTypes			
FROM bankdata
GROUP BY LoanTypes
ORDER BY SuccessRate ASC
```

| SucessRate | LoanTypes     |
|------------|---------------|
| .0098      | Credit Default|
| .0399      | Personal Loan |
| .3604      | Housing Loan  |
| .5899      | No Loans      |

It appears people with housing loans are much more likely to subscribe to a term deposit compared to credit or personal loans. Anyone without loans has the highest chance of success. 

---

To summarize the analysis, we can try to find the most optimal customer demographic to market towards:

First, the marketing call should be done during spring or winter for the highest success rate.

 - The client should only have a house loan or preferably none at all
 - The client should have completed at least secondary education
 - Have a bank balance greater than the average bank client
 - Should be middle-aged or senior (40-70)








