# Use the AWS Lambda Python 3.11 base image
FROM public.ecr.aws/lambda/python:3.11

# Set working directory inside the container
WORKDIR /var/task

# Install system-level packages needed for pandas/pyarrow
RUN yum install -y gcc gcc-c++ python3-devel

# Copy requirements and install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy function code into the container
COPY functions.py ./

# Set the handler function: functions.py + lambda_handler
CMD ["functions.lambda_handler"]
