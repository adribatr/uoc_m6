#!/bin/bash

# Log file
log_file="project/invoke_lambda.log"

# Function to log messages
log_message() {
    local log_text="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $log_text" >> "$log_file"
}

# Function to check if the script is being run with root privileges
check_root_privileges() {
    if [[ $EUID -ne 0 ]]; then
        log_message "This script must be run as root"
        exit 1
    fi
}

# Function to install AWS CLI if not installed
install_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_message "AWS CLI not found. Installing..."
        yum install -y aws-cli
        log_message "AWS CLI installed successfully"
    else
        log_message "AWS CLI is already installed"
    fi
}

# Function to invoke the Lambda function
invoke_lambda_function() {
    local function_name="lambda_m6"
    local payload='{"key1": "value1", "key2": "value2"}' # Adjust payload as needed

    log_message "Invoking Lambda function $function_name with payload: $payload"

    aws lambda invoke \
        --function-name "$function_name" \
        --payload "$payload" \
        response.json \
        --log-type Tail \
        --query 'LogResult' \
        --output text | base64 -d >> "$log_file" 2>&1

    if [[ $? -eq 0 ]]; then
        log_message "Lambda function invoked successfully. Response saved to response.json"
    else
        log_message "Failed to invoke Lambda function"
    fi
}

# Main function to run the script
main() {
    log_message "Starting the script"
    check_root_privileges
    install_aws_cli
    invoke_lambda_function
    log_message "Script execution completed"
}

# Run the main function
main
