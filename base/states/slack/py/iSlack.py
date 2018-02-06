# -*- coding: utf-8 -*-

import os
import sys 
      
from slackclient import SlackClient

SLACK_TOKEN   = os.getenv('SLACK_TOKEN')
SLACK_CHANNEL = os.getenv('SLACK_CHANNEL')

def send_message(message='None'):
    '''
    CLI Example: 
    
    .. code-block:: bash

        salt 'master' iSlack.send_message "$(ls -lrt /root | sed 's,\x1B\[[0-9;]*[a-zA-Z],,g')"
    '''

    slack_client = SlackClient(SLACK_TOKEN)

    slack_client.api_call(
        "chat.postMessage",
        channel=SLACK_CHANNEL,
        text='''{msg}'''.format(msg=message),
        username='irobot',
        icon_emoji=':robot_face:'
    )

    return True 

if __name__ == '__main__':
  send_message(sys.argv[1])
