{% set channel = data['channel'] %}
{% set user    = data['user'] %}
{% set text    = data['text'] %}

{% if channel  == 'xxx'  and 
      user     == 'xxx'  and
      text.strip().startswith('salt')
%}
exec_cmd:
  cmd.cmd.run:
    - tgt: 'master'
    - arg:
      - "salt 'master' state.sls slack.post_message"
{% else %}
exec_cmd:
  cmd.cmd.run:
    - tgt: 'master'
    - arg:
      - 'echo "{{message}}" > /tmp/test.log'
{% endif %}
