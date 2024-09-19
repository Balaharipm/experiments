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

def extract(text):
    url = "https://emsiservices.com/skills/versions/latest/extract"

    querystring = {"language":"en"}
    payload = f'{{ "text": "{text}" }}'
    bearer_token = auth()
    headers = {
    'Authorization': f'Bearer {bearer_token}',
    'Content-Type': "text/plain"
    }

    response = requests.request("POST", url, data=payload, headers=headers, params=querystring)

    response_json = json.loads(response.text)
    skill_names = ""

    for item in response_json['data']:
    # Get skill name
        
        skill_name = item['skill']['name']
    # Append skill name to the string, followed by a newline character
        skill_names += skill_name + '\n' 

    with open('skill_names.txt', 'w') as f:
        f.write(skill_names)

def read_pdf(pdf_file_path):
    text = ""

    # Open the PDF file in binary mode
    with open(pdf_file_path, "rb") as file:
        # Create a PDF reader object
        pdf_reader = PyPDF2.PdfReader(file)

        # Iterate through all pages
        for page_num in range(len(pdf_reader.pages)):
            # Get the page
            page = pdf_reader.pages[page_num]

            # Extract text from the page
            text += page.extract_text()

    return text

pdf_file_path = input("Enter the path to the PDF file: ")

# Call the function to read text from the PDF
try:
    pdf_text = read_pdf(pdf_file_path)
    #print(pdf_text)
    extract(pdf_text)
except FileNotFoundError:
    print(f"Error: File not found at '{pdf_file_path}'")
except Exception as e:
    print(f"An error occurred: {e}")

