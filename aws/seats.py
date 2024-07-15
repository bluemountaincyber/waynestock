#!/usr/bin/env python

import json
import random

total_sections = 3
total_rows = 20
total_seats_per_row = 15

def create_json_file():
    data = {}
    data['seatingChart'] = []
    for section in range(total_sections):
        for row in range(total_rows):
            for seat in range(total_seats_per_row):
                data['seatingChart'].append({
                    'section': section + 1,
                    'row': row + 1,
                    'seat': seat + 1,
                    'seat_id': f'{section + 1}-{row + 1}-{seat + 1}',
                    'available': random.choice([True, False])
                })
    with open('seats.json', 'w') as outfile:
        json.dump(data, outfile)

if __name__ == '__main__':
    create_json_file()