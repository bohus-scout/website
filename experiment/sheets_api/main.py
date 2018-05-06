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
SPREADSHEET_ID = '1YNwms_bIW0PQxLMD6LSZlt0ojcMRW_flwohiKojlnsY'
RANGE_NAME = 'Anmälda!B9:J59'
result = service.spreadsheets().values().get(spreadsheetId=SPREADSHEET_ID,
                                             range=RANGE_NAME).execute()
values = result.get('values', [])

f = open("ledare.html", encoding="utf-8")
result_str = f.read()
f.close()

for value in values:
    if len(value) != 0 and value[1] == "Ledare":
        # result_str += "<tr><td>%s</td><td>%s</td></tr>" % (value[0], value[8])
        result_str += "<tr><td>%s</td></tr>" % (value[0])

f = open("ledare_result.html","w", encoding="utf-8")
f.write(result_str)
f.close()