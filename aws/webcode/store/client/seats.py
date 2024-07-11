#!/usr/bin/env python

import json
import random

total_sections = 3
total_rows = 20
total_seats_per_row = 30

def create_json_file():
    data = {}
    data['seatingChart'] = []
    for section in range(1, total_sections+1):
        data['seatingChart'].append({
            'section': section,
            'rows': []
        })
        for row in range(1, total_rows+1):
            data['seatingChart'][section-1]['rows'].append({
                'row': row,
                'seats': []
            })
            for seat in range(1, total_seats_per_row+1):
                data['seatingChart'][section-1]['rows'][row-1]['seats'].append({
                    'seat': seat,
                    'available': True if random.random() < 0.5 else False
                })
    with open('src/components/seats.json', 'w') as outfile:
        json.dump(data, outfile)

if __name__ == '__main__':
    create_json_file()