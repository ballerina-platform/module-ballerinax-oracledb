connect sys/Oradoc_db1 as sysdba;
alter session set "_ORACLE_SCRIPT"=true;
create user admin identified by password;
grant connect, resource,dba to admin;