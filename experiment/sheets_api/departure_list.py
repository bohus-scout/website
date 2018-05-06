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
RANGE_NAME = 'Anmälda!A9:I62'
result = service.spreadsheets().values().get(spreadsheetId=SPREADSHEET_ID,
                                             range=RANGE_NAME).execute()
values = result.get('values', [])
with open("departure.html", encoding="utf-8") as f:
    result_str = f.read()


sp = ""
up = ""
av = ""
ut = ""
others = ""
a = "SpårareUpptäckareÄventyrareUtmanare"
for value in values:
    print(value)
    if value[1] in a:
        if value[1] == "Spårare":
            sp += ("<tr><td></td><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (value[0], value[1], value[8]))
        elif value[1] == "Upptäckare":
            up += ("<tr><td></td><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (value[0], value[1], value[8]))
        elif value[1] == "Äventyrare":
            av += ("<tr><td></td><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (value[0], value[1], value[8]))
        elif value[1] == "Utmanare":
            ut += ("<tr><td></td><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (value[0], value[1], value[8]))
    elif "To" in value[2]:
        others += ("<tr><td></td><td>%s</td><td>%s</td><td>%s</td></tr>\n" % (value[0], value[1], value[8]))    
        
result_str += sp + up + av + ut + others

with open("result.html", "w", encoding="utf-8") as f:
    f.write(result_str)
