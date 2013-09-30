'''
Script to update the AFH/AFHk Achievements spreadsheet
it depends on pykol and they python bindings to gdata (the google docs api)
you also need a google documents account and a kol account.
fill_spread.py uses a configfile (defaults to fill_spread.cfg overridden with a argument of -c) that looks like:
----
[google]
user=<username>
passwd=<password>
sheet=<spreadsheet name>

[kol]
user=<username>
passwd=<password>
---

also can optionally take an argument -starts to limit to only those runs after starting date
or -ends to those only ending before date (dates are inclusive)

example execution:
python fill_spread.py -c fill_spread.cfg -ends 2011/6/30

when invocated the script logs into google document and examines the spreadsheet
named in the config file, and grabs all the character names in the first column.
it then logs into KoL and scrapes their ascension history finding their fastest
runs of each type, and updates the spreadsheet with the days/turn count and date
of the run.
'''

import gdata.spreadsheet.service

from kol.Session import Session
from kol.request.AscensionHistoryRequest import AscensionHistoryRequest
from kol.request.SearchPlayerRequest import SearchPlayerRequest

import argparse
import ConfigParser
import datetime


def parsedate(d):
    '''
    parse a string in the YYYY/MM/DD format into a date object returning a 
    datetime.date object
    '''
    y,m,d = d.split('/')
    return(datetime.date(int(y),int(m),int(d)))


def _CellsUpdateAction(spr_client, row,col,inputValue,key,wksht_id):
    '''
    update a spreadsheet cell (row/col) with values
    '''
    entry = spr_client.UpdateCell(row=row, col=col, inputValue=inputValue,
            key=key, wksht_id=wksht_id)
    #if isinstance(entry, gdata.spreadsheet.SpreadsheetsCell):
    #    print 'Updated!'


def google_login(username, passwd, sheet_name):
    '''
    login to google docs and select the named spread sheet
    '''
    client = gdata.spreadsheet.service.SpreadsheetsService()
    # Authenticate using your Google Docs email address and password.
    client.ClientLogin(username, passwd)

    feed = client.GetSpreadsheetsFeed()
    for document_entry in feed.entry:
        if document_entry.title.text == sheet_name:
            
            id_parts = document_entry.id.text.split('/')
            curr_key = id_parts[len(id_parts) - 1]
            
            print curr_key
            sfeed = client.GetWorksheetsFeed(curr_key)
            id_parts = sfeed.entry[0].id.text.split('/') # sheet number 1 for the second worksheet
            curr_wksht_id = id_parts[len(id_parts) - 1]
            
    return client, curr_key, curr_wksht_id


def get_names(client, curr_key, curr_wksht_id):
    '''
    look up the names of the ascender's we want records for
    '''
    names = {}
    
    tmp = client.GetCellsFeed(key=curr_key, wksht_id=curr_wksht_id)
    
    for i, entry in enumerate(tmp.entry):
        row = int(entry.cell.row)
        col = int(entry.cell.col)
        if row > 2 and col == 1:
            #print "(%d,%d) %s" % (row, col, entry.content.text)
            names[entry.content.text.lower()] = row
            
    return names


def update_spread(cells, batchRequest, base_index, ascs):
    '''
    iterate over users, and thier fastest runs and update spreadsheet
    '''
    maxCol = 61
    cols = { 'HCNP' : 4,
            'HCB': 6,
            'HCT': 8,
            'HCO': 10,
            'BM': 12,
            'SCNP': 14,
            'SCB': 16,
            'SCT': 18,
            'SCO': 20,
            'HCBHY': 22,
            'SCBHY': 24,
            'HCWSF': 26,
            'SCWSF': 28,
            'HCTR': 30,
            'SCTR': 32,
            'HCAOB': 34,
            'SCAOB': 36,
            'HCBBI': 38,
            'SCBBI': 40,
            'HCZS': 42,
            'SCZS': 44,
            'HCCA': 46,
            'SCCA': 48,
            'HCAOJ': 50,
            'SCAOJ': 52,
            'HCBIG': 54,
            'SCBIG': 56,
            'HCHS': 58,
            'SCHS': 60}
    # Remember to adjust the maxCol variable when adding new challenge paths; it should be an odd number due to the dates
    

    for type in ascs.keys():
        asc = ascs[type]
        if type in cols:
            col = cols[type]

            date = "%d/%d/%d" % (asc['start'].month, asc['start'].day, asc['start'].year)
            entry = cells.entry[base_index + col - 1]
            entry.cell.inputValue = "%d/%d" %(asc['days'],asc['turns'])
            batchRequest.AddUpdate(entry)

            entry = cells.entry[base_index + col]
            entry.cell.inputValue = date
            batchRequest.AddUpdate(entry)



            #_CellsUpdateAction(client, row, col, "%d/%d" %(asc['days'],asc['turns']), curr_key, curr_wksht_id)
            #_CellsUpdateAction(client, row, col+1, date, curr_key, curr_wksht_id)
        else: # skip b/c we don't know what column to put it in
            pass
    
        
def get_uids(s,names):
    '''
    given a list of names, find thier kol user ids
    '''
    uids = {}
    print "----- Getting names ----- "
    
    for name in names:
        print name
        name = name.lower()
        r = SearchPlayerRequest(s,name)
        responseData = r.doRequest()
        players = responseData['players']
        for player in players:
            if player['userName'].lower() == name:
                uids[name] = player['userId']
    print "----- Done getting names -------"
    return uids


def get_hist(s,uid, starts=None, ends=None):
    '''
    given a kol user id, look up their fastest runs (within dates)
    '''
    rslt = {}
    ascr = AscensionHistoryRequest(s, uid)
    responseData = ascr.doRequest()
    his = responseData["ascensions"]
    for asc in his:
        if asc['mode'] == 'Casual':
            pass # we don't care about casual
        elif starts is not None and asc['start'] < starts:
            pass # too soon
        elif ends is not None and asc['end'] > ends:
            pass # too late
        else:
            type = lookup_mode_path(asc['mode'],asc['path'])
            if type in rslt:
                if asc['days'] < rslt[type]['days']:
                    rslt[type] = asc
                elif asc['days'] == rslt[type]['days'] and asc['turns'] < rslt[type]['turns']:
                    rslt[type] = asc
            else:
                rslt[type] = asc
    return rslt


def lookup_mode_path(mode,path):
    '''
    lookup table like function for a given mode (HC/SC/BM) and path
    returns the more commonly used HCNP/SCO/HCBHY etc
    '''
    if mode == 'Casual':
        rslt = 'Casual'
    elif mode == 'Softcore':
        rslt = 'SC'
    elif mode == 'Hardcore':
        rslt = 'HC'
    else:
        rslt = 'BM'
        
    if path == 'None':
        if rslt != 'BM':
            rslt = rslt + "NP"

    elif path == "Oxygenarian":
        rslt = rslt + "O"
    elif path == "Boozetafarian":
        rslt = rslt + "B"
    elif path == "Teetotaler":
        rslt = rslt +"T"
    elif path == "Way of the Surprising Fist":
        rslt = rslt +"WSF"
    elif path == "Bees Hate You":
        rslt = rslt+"BHY"
    elif path == "Trendy":
        rslt = rslt + "TR"
    elif path == "Avatar of Boris":
        rslt = rslt + "AOB"
    elif path == "Bugbear Invasion":
        rslt = rslt + "BBI"
    elif path == "Zombie Slayer":
        rslt = rslt + "ZS"
    elif path == "Class Act":
        rslt = rslt + "CA"
    elif path == "Avatar of Jarlsberg":
        rslt = rslt + "AOJ"
    elif path == "BIG!":
        rslt = rslt + "BIG"
    elif path == "KOLHS":
        rslt = rslt + "HS"
    elif path == "Bad Moon":
        pass
    else:
        raise Exception('unknown path: %s' % path)
        
    return rslt

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update the AFH spreadsheet')
    parser.add_argument('-c', metavar='config_file', type=argparse.FileType('r'),
                nargs='?', default='fill_spread.cfg',
                help='config file for fill_spread.py')
    
    parser.add_argument('-ends', metavar='YYYY/M/D', type=str,
                        nargs='?', default=None,
                        help='date at which runs must finished by')
    parser.add_argument('-starts', metavar='YYYY/M/D', type=str,
                        nargs='?', default=None,
                        help='date at which runs must have started by')
    

    args = parser.parse_args()
    
    if args.ends is not None:
        ends = parsedate(args.ends)
    else:
        ends = None
        
    if args.starts is not None:
        starts = parsedate(args.starts)
    else:
        starts=None

    config = ConfigParser.RawConfigParser(allow_no_value=True)
    config.readfp(args.c)
    
    guser = config.get('google','user')
    gpwd = config.get('google','passwd')
    gsheet = config.get('google','sheet')

    print "Logging in to google"
    client, curr_key, curr_wksht_id = google_login(guser,gpwd,gsheet)
    print "google login complete; getting names"
    nrl = get_names(client, curr_key, curr_wksht_id) #get names and thier row

    names = nrl.keys() # list of names
    print "names got!"
    fastest = {}
    # Login to the KoL servers.
    s = Session()
    print "About to login to KOL"
    s.login(config.get('kol','user'), config.get('kol','passwd'))
    print "Kol login complete.  Getting uids"    
    uids = get_uids(s,names) # lookup uids from names
    print "Uids got!"
    
    # Prepare a batch operation for updating the spreadsheet
    maxCol = 61
    query = gdata.spreadsheet.service.CellQuery()
    query.return_empty = "true" 
    query.min_row = "3"
    query.max_row = "%i" % (2 + len(names))
    query.min_col = "1"
    query.max_col = "%i" % (maxCol)

    cells = client.GetCellsFeed(curr_key, wksht_id=curr_wksht_id, query=query)
    batchRequest = gdata.spreadsheet.SpreadsheetsCellsFeed()




    #for each users grab their fastest ascensions and queue an update to spreadsheet with them
    for name, uid in uids.items():
        print name
        fastest[name] = get_hist(s, uid, starts, ends)
        print name, fastest[name].keys()
        row = nrl[name]
        update_spread(cells, batchRequest, maxCol*(row-3), fastest[name])

    # Write out all the batched updates
    updated = client.ExecuteBatch(batchRequest, cells.GetBatchLink().href)
    s.logout()
