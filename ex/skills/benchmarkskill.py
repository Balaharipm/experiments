import requests
import json
import PyPDF2
CLIENT_ID="k5mli83dw6qfbyzb"
CLIENT_SECRET="50U58KUj"
def auth():
    url = "https://auth.emsicloud.com/connect/token"

    payload = f"client_id={CLIENT_ID}&client_secret={CLIENT_SECRET}&grant_type=client_credentials&scope=benchmark"
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}

    response = requests.request("POST", url, data=payload, headers=headers)

# Parse the response text as JSON
    response_json = json.loads(response.text)
    print(response_json)
# Extract the bearer token
    bearer_token = response_json['access_token']

    print(bearer_token)
    return bearer_token

bearer_token=auth()
url = "https://emsiservices.com/benchmark/"

payload = "{ \"title\": \"Cloud Engineer\", \"city\": \"Seattle, WA\" }"
headers = {
    'Authorization': f'Bearer {bearer_token}',
    'Content-Type': "application/json"
    }

response = requests.request("POST", url, data=payload, headers=headers)

print(response.text)