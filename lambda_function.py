import io
import os
import re
import pandas as pd
import boto3
import logging
import pymysql
import mysql
from sqlalchemy import create_engine
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    database_endpoint = os.environ['database_endpoint']
    database_username = os.environ['database_username']
    database_password = os.environ['database_password']
    database_name     = os.environ['database_name']

    try:
        conn = pymysql.connect(
            host=database_endpoint,
            user=database_username,
            passwd=database_password,
            database=database_name,
            port = 3306
        )

        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            result = cur.fetchone()
            logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")
            logger.info(f"Query result: {result}")
        return "Connection to RDS for MySQL instance succeeded"
    except pymysql.MySQLError as e:
        logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
        logger.error(e)
        return "ERROR: Unexpected error: Could not connect to MySQL instance."
