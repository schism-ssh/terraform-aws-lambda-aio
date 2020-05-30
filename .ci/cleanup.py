#!/usr/bin/env python3
# -* coding: utf-8 -*-

import os
import boto3

bucket = '{}-certificates'.format(os.environ['TF_VAR_prefix'])

s3 = boto3.client('s3')
paginator = s3.get_paginator('list_object_versions').paginate(Bucket=bucket)

objects = []

for response in paginator:
    objects.extend([v for v in response.get('Versions', [])])
    objects.extend([m for m in response.get('DeleteMarkers', [])])

for o in objects:
    s3.delete_object(Bucket=bucket, Key=o['Key'], VersionId=o['VersionId'])
