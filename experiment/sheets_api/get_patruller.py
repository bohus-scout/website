"""
Shows basic usage of the Sheets API. Prints values from a Google Spreadsheet.
"""
from __future__ import print_function
from apiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools

# Setup the Sheets API
SCOPES = 'https://www.googleapis.com/auth/spreadsheets.readonly'
store = file.Storage('credentials.json')
creds = store.get()
if not creds or creds.invalid:
    flow = client.flow_from_clientsecrets('client_secret.json', SCOPES)
    creds = tools.run_flow(flow, store)
service = build('sheets', 'v4', http=creds.authorize(Http()))

# Call the Sheets API
SPREADSHEET_ID = '1gAUj8DABD2l6izE7IWxVB4JOYL3D8JUq6jebxE83loQ'
RANGE_NAME = 'Patruller!A2:C41'
result = service.spreadsheets().values().get(spreadsheetId=SPREADSHEET_ID,
                                             range=RANGE_NAME).execute()
values = result.get('values', [])

print(values)

patrullnummer = ""

for value in values:
    if len(value) != 0:
        if value[0] != "":
            patrullnummer = value[0]
            print(patrullnummer)

        print(value[2] + " " + value[1])
    
