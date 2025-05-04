# import torch
import json

model = None

# def load_model():
#     global model
#     if model is None:
#         model = torch.load('/opt/model/model.pth', map_location=torch.device("cpu"))
#         model.eval()

def lambda_handler(event, context):
    # load_model()

    # body = json.loads(event["body"])
    # input_tensor = torch.tensor(body["input"]).float()
    # with torch.no_grad():
    #     output = model(input_tensor)
    response = {
        "statusCode": 200,
        "body": json.dumps({
            # "output": output.tolist()
            "output": "hello world"
        })
    }
    return response