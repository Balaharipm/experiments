import requests
import json
import PyPDF2
CLIENT_ID="k5mli83dw6qfbyzb"
CLIENT_SECRET="50U58KUj"
def auth():
    url = "https://auth.emsicloud.com/connect/token"

    payload = f"client_id={CLIENT_ID}&client_secret={CLIENT_SECRET}&grant_type=client_credentials&scope=emsi_open"
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}

    response = requests.request("POST", url, data=payload, headers=headers)

# Parse the response text as JSON
    response_json = json.loads(response.text)

# Extract the bearer token
    bearer_token = response_json['access_token']

    print(bearer_token)
    return bearer_token

def extract():
    url = "https://emsiservices.com/skills/versions/latest/skills"

    querystring = {"fields":"name"}
    bearer_token = auth()
    headers = {
    'Authorization': f'Bearer {bearer_token}',
    }

    response = requests.request("GET", url, headers=headers, params=querystring)

    response_json = json.loads(response.text)
    skill_names = ""

    for item in response_json['data']:
    # Get skill name
        
        skill_name = item['name']
    # Append skill name to the string, followed by a newline character
        skill_names += skill_name + '\n' 
    print (skill_names)
    with open('all_skill_names.txt', 'w', encoding='utf-8') as f:
        f.write(skill_names)


auth()
extract()