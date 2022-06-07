# Rearc Data Quest

The following are notes/steps I took when exploring [rearc-data/quest](https://github.com/rearc-data/quest). Note that I'm new to some of these technologies and procedures, and that some of these notes may be over-detailed but were useful for my reference while exploring the quest.

## Part 1

> 1. Republish [this open dataset](https://download.bls.gov/pub/time.series/pr/) in Amazon S3 and share with us a link.

- Made a publicly accessible bucket on Amazon S3. Here's a file listing: [].
- Downloaded and uploaded files from the open dataset to the S3 bucket.
- Changed permissions by turning off "Block public access" and editing the bucket policy. Completed these steps while following [this guide](https://www.simplified.guide/aws/s3/create-public-bucket) to provide read-only permissions to users. Here's the bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Principal": "*",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::data-quest-bucket/*"
    }
  ]
}
```

> 2. Script this process so the files in the S3 bucket are kept in sync with the source when data on the website is updated, added, or deleted.

- Made a Python script `sync_data.py` to sync data source with S3 bucket.
- Based on part 4 question 2, I would be running this script on a daily basis. Locally I would use [Windows Task Scheduler](https://www.geeksforgeeks.org/schedule-a-python-script-to-run-daily/).
- Set up a virtual environment to use packages:
  - `boto3`
  - `bs4`
  - `requests`
- References
  - [RealPython Web Scraping with Python article - BeautifulSoup4 HTML Parser](https://realpython.com/python-web-scraping-practical-introduction/#use-an-html-parser-for-web-scraping-in-python)
  - [RealPython Boto3 and AWS S3 article](https://realpython.com/python-boto3-aws-s3/)
  - [Boto3 Docs - S3 service reference](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html)

> 3. Don't rely on hard coded names - the script should be able to handle added or removed files.

- The script implementation only specifies `a` elements to access each downloadable resource, not by specific file names.
- The script handles added or removed files.
- Based on the HTML of the data source, I would need to specify which `a` elements to include for upload.
- Assumptions:
  - There is an `a` element with text content `[To Parent Directory]` which will be omitted from processing within the script.
  - No directories are on the data source page, only direct files.

> 4. Ensure the script doesn't upload the same file more than once.

The script logic prevents uploading the same file more than once since files in the data source and their corresponding S3 object keys have the same name. This helps check if a file exists as an S3 object since the object key is unique in an S3 bucket.

Script logic:

- If data source file not in S3
  - Upload to S3
- If data source file in S3
  - If data source file differs from S3 file
    - Update S3 file
  - If data source file is the same as S3 file
    - Do nothing
- Remove S3 files that don't exist in data source

## Part 2

## Part 3

## Part 4
