#!/bin/bash
TOKEN=$(aws ecr get-login-password --region us-east-1)
echo "{\"password\": \"$TOKEN\"}"