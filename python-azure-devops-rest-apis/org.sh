#!/bin/bash

# Set your organization details and PAT
ORG="myorganization"
PROJECT="myproject"
PAT="your-personal-access-token"

# Create the base64 encoded auth header
# The username can be anything - only the PAT matters
AUTH=$(echo -n ":${PAT}" | base64)

# Test the connection by listing projects
curl -s -H "Authorization: Basic ${AUTH}" \
  "https://dev.azure.com/${ORG}/_apis/projects?api-version=7.1" | jq '.value[].name'