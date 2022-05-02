import os
import boto3
from botocore.exceptions import ClientError


def create_bucket(bucket_name, s3_resource, region):
    try:
        s3_resource.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={'LocationConstraint': region})

        s3_resource.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            },
        )
    except ClientError as e:
        print(e)
        return False
    return True


def upload_file_to_bucket(bucket, folder, file_to_upload, filename, s3_client):
    key = folder + "/" + filename
    try:
        response = s3_client.upload_file(file_to_upload, bucket, key)
    except ClientError as e:
        print(e)
        return False
    except FileNotFoundError as e:
        print(e)
        return False
    return True


directory = "c:\\demo\\SSL"
bucket_to_upload = 'demo-samir-aims3'
bucket_region = 'us-east-2'

client_connect = boto3.client('s3')

listBucket = client_connect.list_buckets()
list_bucket_name = []

for bucketName in listBucket['Buckets']:
    list_bucket_name.append(bucketName['Name'])

if bucket_to_upload not in list_bucket_name:
    create_bucket(bucket_to_upload, client_connect, bucket_region)

if bucket_to_upload:
    for root, dirs, files in os.walk(directory, topdown=True):
        for file_name in files:
            full_path_file = os.path.join(root, file_name)
            directory_name_with_file = os.path.relpath(full_path_file, directory)
            directory_name = '/'.join(directory_name_with_file.split('\\')[0:-1])
            upload_file_to_bucket(bucket_to_upload, directory_name, full_path_file, file_name, client_connect)
            print("File Uploaded From Local Directory " + full_path_file + " to Remote Cloud S3 at " + directory_name + "/" + file_name)
