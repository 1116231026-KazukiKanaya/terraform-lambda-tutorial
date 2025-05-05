import json
import random

def lambda_handler(event, context):
    fortunes = ["大吉", "中吉", "小吉", "吉", "凶", "大凶"]
    selected_fortune = random.choice(fortunes)
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*"
        },
        "body": json.dumps({"fortune": selected_fortune})
    }