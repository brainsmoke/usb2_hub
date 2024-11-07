
# correct rotations / component placement for JLCPCB

import csv, sys, decimal
from math import cos, sin, radians

boardhouse = sys.argv[1]

r = csv.DictReader(sys.stdin)

in_cols = [ 'Ref','Val','Package','PosX','PosY','Rot','Side' ]
out_cols = [ 'Designator','Val','Package','Mid X','Mid Y','Rotation','Layer' ]

out = csv.DictWriter(sys.stdout, fieldnames = out_cols, dialect = "unix")
out.writeheader()

corrections = {

    'jlc': {

		'AP2112K-3.3'  : { 'pos': ('0','0'), 'rot': '-90' },
        'AP22652AW6-7' : { 'pos': ('0','0'), 'rot': '-90' },
        'USBLC6-2SC6'  : { 'pos': ('0','0'), 'rot': '-90' },
        'FE1.1'        : { 'pos': ('0','0'), 'rot': '-90' },
		'STM32F042G6Ux': { 'pos': ('0','0'), 'rot': '-90' },
        'USB_C_Receptacle_USB2.0'
                       : { 'pos': ('0','1.45'), 'rot': '0' },
        'USB_C_Receptacle_USB2.0_16P'
                       : { 'pos': ('0','1.45'), 'rot': '0' },
    }
}

def process(row, boardhouse='jlc'):
    change = corrections[boardhouse].get(row['Val'])
    if change:
        rot = ( decimal.Decimal(row['Rotation']) + decimal.Decimal(change['rot']) ) % 360
        row['Rotation'] = f"{rot:.6f}"

        t = radians(float(rot))
        x, y = float(row['Mid X']), float(row['Mid Y'])
        dx, dy = [ float(x) for x in change['pos'] ]
        new_x, new_y = x+cos(t)*dx - sin(t)*dy, y + sin(t)*dx + cos(t)*dy
        row['Mid X'] = f"{new_x:.6f}"
        row['Mid Y'] = f"{new_y:.6f}"

    return row
    

for row in r:
    new_row = { y:row[x] for x,y in zip(in_cols, out_cols) }
    out.writerow( process(new_row, boardhouse) ) 

