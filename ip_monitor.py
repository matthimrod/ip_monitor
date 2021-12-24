#!/usr/bin/python3

import logging
import os
import requests
import smtplib
import socket
import ssl
import yaml

CONFIG_FILENAME = "ip_monitor.yml"

config = []
with open(CONFIG_FILENAME, 'r') as stream:
    try:
        config = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

logging.basicConfig(filename=config['config']['log_filename'], encoding='utf-8', level=logging.INFO, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %H:%M:%S')

def email(message):
    email_text = f"""\
From: {config['config']['email_from']}
To: {config['config']['email_to']}
Subject: IP Address Monitor

{message}
"""

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(config['config']['username'], config['config']['password'])
        server.sendmail(config['config']['email_from'], config['config']['email_to'], email_text)
        server.close()

        logging.warning('Email sent to %s.', config['config']['email_to'])
    except Exception as e:
        logging.error('Something went wrong while sending the failure email.')
        print(e)


result = requests.get(config['config']['api_url'])

if result.status_code != requests.codes.ok:
    message = f'IP API call failed. {result.text}'
    logging.error(message)
    email(message)
    config['last_address'] = 'error'
elif result.text != config['last_address']:
    message = f'The Public IP Address has changed from {config["last_address"]} to {result.text}.'
    logging.info(message)
    email(message)
    config['last_address'] = result.text
else:
    logging.info(f'Public IP unchanged: {result.text}')

with open(CONFIG_FILENAME, 'w') as stream:
    yaml.dump(config, stream, default_flow_style=False) 