{% set salt_token   = grains['SLACK_TOKEN']   %}
{% set salt_channel = grains['SLACK_CHANNEL'] %}

salt://slack/shell/iSlack.sh:
  cmd.script:
    - env:
      - SALT_STATE_HOME: '/srv/salt/iSaltstack/base/states'
      - SLACK_TOKEN: '{{salt_token}}'
      - SLACK_CHANNEL: '{{salt_channel}}'
    - runas: root
