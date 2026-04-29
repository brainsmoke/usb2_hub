
# correct rotations / component placement for JLCPCB

import csv, sys, decimal
from math import cos, sin, radians

boardhouse = sys.argv[1]

posfile = open(sys.argv[2], 'r')
records = csv.DictReader(posfile)

bomfile = open(sys.argv[3], 'r')
bom_records = { r['Reference'] : r for r in csv.DictReader(bomfile) }

in_cols = [ 'Ref','Val','Package','PosX','PosY','Rot','Side' ]

out_cols = {
    'jlc' : [ 'Designator','Val','Package','Mid X','Mid Y','Rotation','Layer' ]
}

out = csv.DictWriter(sys.stdout, fieldnames = out_cols[boardhouse], dialect = "unix")
out.writeheader()

partno_field_name = {
    'jlc' : 'LCSC'
}

corrections = {

    'jlc': {

		# AP2112K-3.3
        'C51118' : { 'pos': ('0','0'), 'rot': '-90' },

        # AP22652AW6-7
        'C5329413' : { 'pos': ('0','0'), 'rot': '-90' },

        # USBLC6-2SC6
        'C7519' : { 'pos': ('0','0'), 'rot': '-90' },

        # USBLC6-2P6
        'C15999' : { 'pos': ('0','0'), 'rot': '-180' },

        # FE1.1
        'C28958' : { 'pos': ('0','0'), 'rot': '-90' },

        # STM32F030F4Px
        'C89040' : { 'pos': ('0','0'), 'rot': '-90' },

		# STM32F042G6Ux
        'C961597' : { 'pos': ('0','0'), 'rot': '-90' },

        # STM32F072C8Tx
        'C81720' : { 'pos': ('0','0'), 'rot': '-90' },

        # USB_C_Receptacle_USB2.0
        'C165948' : { 'pos': ('0','1.45'), 'rot': '0' },

        # TLC5916IPWR
        'C193571' : { 'pos': ('0','0'), 'rot': '-90' },

        # STP08CP05TTR
        'C2678539' : { 'pos': ('0','0'), 'rot': '-90' },

        # 74LVC2G17
        'C10429' : { 'pos': ('0','0'), 'rot': '-90' },

        # TLP2361
        'C107626' : { 'pos': ('0','0'), 'rot': '180' },

    }
}

bottom_rotation = {
    'jlc' : lambda r : 180-r,
}

def process(row, boardhouse='jlc'):

    field = bom_records[row['Ref']][partno_field_name[boardhouse]]
    change = corrections[boardhouse].get(field)

    rot = decimal.Decimal(row['Rot'])
    layer = row['Side']

    if change:
        orient = { 'top': 1, 'bottom': -1 }[layer]

        rot += decimal.Decimal(change['rot']) * orient

        t = radians(float(rot))
        x, y = float(row['PosX']), float(row['PosY'])
        dx, dy = [ float(x) for x in change['pos'] ]

        dy = dy * orient

        new_x, new_y = x+cos(t)*dx - sin(t)*dy, y + sin(t)*dx + cos(t)*dy
        row['PosX'] = f"{new_x:.6f}"
        row['PosY'] = f"{new_y:.6f}"

    if layer == 'bottom':
        rot = bottom_rotation[boardhouse](rot)

    rot %= 360
    row['Rot'] = f"{rot:.6f}"

    return row
    

for row in records:
    processed_row = process(row, boardhouse)
    new_row = { y:processed_row[x] for x,y in zip(in_cols, out_cols[boardhouse]) }
    out.writerow( new_row )

