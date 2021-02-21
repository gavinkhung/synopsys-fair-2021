```bash
sls plugin install -n serverless-python-requirements
sls plugin install -n serverless-wsgi

python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

sls wsgi serve

# make sure to open docker before deploying
sls deploy --stage prod

sls remove --stage prod
```

{
"Action": [
"sagemaker:InvokeEndpoint"
],
"Resource": [
"arn:aws:sagemaker:us-west-1:091726233116:endpoint/*"
],
"Effect": "Allow"
}
