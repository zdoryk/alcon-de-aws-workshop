# Data Engineering Workshop

## Introduction
You will be working with a dataset of patients in the hospital.

Imagine that you have not only historic data, but new data is constantly coming from the data source. 
Your main goal is to create a Data Lake on which we will have data for each separate day and hour in a separate file. For example:

```
S3_Bucket/enriched
|- 10-10-2023_11.parquet
|- 11-10-2023_12.parquet
```

In this case you will need to create a job that will run every hour. 
1. It will read the data from the data source.
2. Put it to <s3_bucket>/raw/<date>_<hour>.csv
3. Read the data from <s3_bucket>/raw/<date>_<hour>.csv
4. Clean it.
5. Put it to <s3_bucket>/trusted/<date>_<hour>.csv
6. Read the data from <s3_bucket>/trusted/<date>_<hour>.csv
7. Enrich it.
8. Put it to <s3_bucket>/enriched/<date>_<hour>.parquet

In the very end, if you will done all the steps correctly, you will have a Data Lake with the following structure:

```
S3_Bucket
|- raw
|  |- 10-10-2023_11.csv
|  |- 11-10-2023_12.csv
|- trusted
|  |- 10-10-2023_11.csv
|  |- 11-10-2023_12.csv
|- enriched
|  |- 10-10-2023_11.parquet
|  |- 11-10-2023_12.parquet
```

Using Athena you will be able to query the data that you will have in the enriched folder, just simply running SQL queries.

## Task Overview
### RAW Step:
You will need to make a GET request to this endpoint: "https://43bhzz3c3f.execute-api.us-east-1.amazonaws.com/v1/data". To get the data, provide the following query parameters:

1. Date in the format: "dd-mm-yyyy".
2. Start time in the format: "HH:mm".
3. End time in the format: "HH:mm".

Also, provide the AUTH_TOKEN, which you can read from your `.env` file. Read this environment variable from the file using Python code. The token should be included in the headers as "Authorization: Bearer <TOKEN>".

**NOTE: Use the "requests" library from Python to make a request to the API endpoint.**

Useful links:
- About HTTP requests in general: [Mozilla Developer - HTTP Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
- About Python requests library: [Requests Documentation](https://requests.readthedocs.io/en/latest/user/quickstart/)

### TRUSTED Step:
Validate the data in the "AGE" column to ensure it makes sense. If this column has any problems, please fix them to work automatically in the future. For example, ensure that there are:

- No negative ages (Handling Invalid Ages).
- No ages that are unrealistically high (Identify Outliers).
- No missing ages (Identify Missing Values).

**NOTE: In the context of this workshop, you can filter those values. There is no need for now to implement comprehensive approaches to handling this, but feel free to explore more complex solutions after the workshop in your free time.**

### ENRICHED Step:
1. Create a new column called "is_dead," which will be a boolean column with "True" and "False" values. "False" means that the patient is alive, and "True" means that the patient is dead. If the patient has an actual date in the "DATE_DIED" column, it means that the patient has died. If the patient has "9999-99-99" in the "DATE_DIED" column, it means that the patient is alive.

2. Create a new column using the columns "SEX," "AGE," "FIRST_NAME," and "LAST_NAME." This new column should contain the full name of the patient in the following format: "FIRST_NAME LAST_NAME." If the person is older than 21 years old, use "Mr" or "Mrs" based on gender. For example: "Mr. John Smith" or "Mrs. Jane Smith" for patients older than 21 years old. Use "Danylo Zdoryk" if the patient is younger than 21 years old.

3. Age Grouping: Create a new column "AGE_GROUP" by grouping ages into bins with a 10-year step (e.g., 0-9 years, 10-19 years, etc.) and assign each patient to their respective age group. It's better to determine the maximum age dynamically from the AGE column.

## Notes
- Please use the Pandas library for all data manipulation, which can be found here: [Pandas Documentation](https://pandas.pydata.org/docs/).
- Use .utcnow() to get the current time in UTC format. The time on AWS servers can differ from your local time.
- You can debug your jobs right in the Lambda and Glue services, but to permanently save the changes, you will need to update the code in the repository.