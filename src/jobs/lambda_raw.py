import requests
from os import getenv
from datetime import datetime, timedelta
import pandas as pd
import json
import logging
import awswrangler as wr
import boto3


def get_data_df():
    logging.info('Getting data from API')
    headers = {
        "Authorization": f"Bearer {getenv('AUTH_TOKEN')}"
    }
    today = datetime.today()
    start_time = '10:00'
    end_time = '23:59'

    api_base_url = 'https://vnl75agc42.execute-api.us-east-1.amazonaws.com/v1'
    # Get data from the API
    response = requests.get(
        f"{api_base_url}/data?date={today.strftime('%d-%m-%Y')}&start_time={start_time}&end_time={end_time}",
        headers=headers
    )
    return pd.DataFrame(response.json())


def main(handler=None, context=None):
    logging.info('Starting lambda_raw job')
    # Get data from API
    df = get_data_df()
    session = boto3.Session()

    # Write data to S3
    wr.s3.to_csv(
        df=df,
        path=f's3://{getenv("S3_BUCKET_NAME")}/raw/{datetime.today().strftime("%d-%m-%Y")}.csv',
        boto3_session=session,
        index=False
    )
    return {"status": "OK"}


if __name__ == '__main__':
    # Only for local development
    from dotenv import load_dotenv

    load_dotenv()
    main()
