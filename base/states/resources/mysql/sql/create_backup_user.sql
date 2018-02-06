use mysql;

drop function if exists monitor_activity;

delimiter ;;

create function monitor_activity(max_sess_cnt int,max_wait_secs int)
returns int
reads sql data
begin
  declare v_max_loop_cnt int default 1080;
  declare v_sleep_secs int default 10;
  declare v_wait_secs int default 60;
  declare v_sess_cnt int default 0;
  declare v_loop_cnt int default 0;
  declare v_dummy varchar(50);
  while_loop:while v_loop_cnt < v_max_loop_cnt
  do
    select count(*) cnt
      into v_sess_cnt
    from information_schema.processlist
    where upper(command)<>upper('sleep')
          and time > max_wait_secs;
    if v_sess_cnt > max_sess_cnt then
      leave while_loop;
    end if;
    set v_loop_cnt := v_loop_cnt + 1;
    select sleep(v_sleep_secs) slp into v_dummy;
  end while;
  if v_loop_cnt = v_max_loop_cnt then
    return 0;
  else
    return 1;
  end if;
end;;

delimiter ;

create user xxx@localhost identified by 'xxx';

grant select on *.* to xxx@'localhost';
grant lock tables on *.* to xxx@'localhost';
grant reload on *.* to xxx@'localhost';
grant show databases on *.* to xxx@'localhost';
grant process on *.* to xxx@'localhost';
grant super,replication client on *.* to xxx@'localhost';
grant show view on *.* to xxx@localhost;
grant execute on function mysql.monitor_activity to xxx@localhost;
