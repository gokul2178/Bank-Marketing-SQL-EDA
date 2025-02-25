DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

CREATE TABLE bankData (
    age INT,
    job VARCHAR(50),
    marital VARCHAR(50),
    education VARCHAR(50),
    `default` VARCHAR(50),
    balance INT,             
    housing VARCHAR(50),
    loan VARCHAR(50),
    contact VARCHAR(50),
    `day` INT,                     
    `month` VARCHAR(5),
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    poutcome VARCHAR(30),
    y VARCHAR(30)
);


-- The data is manually uploaded to C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ in this project
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Bank_Marketing.csv"
INTO TABLE bankData
FIELDS TERMINATED BY ";"
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 ROWS
(
    age,
    job,
    marital,
    education,
    `default`,
    balance,
    housing,
    loan,
    contact,
    `day`,
    `month`,
    duration,
    campaign,
    pdays,
    previous,
    poutcome,
    y
);
