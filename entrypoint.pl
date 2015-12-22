#!/usr/bin/perl
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 2.0(20150107)
#
# 初衷: 每个容器用不同用户运行程序,已方便在宿主中直观的查看.
# 需求: 1. 动态添加用户,不能将添加用户的动作写死到images中.
#       2. 容器内尽量不留无用进程,保持进程树干净.
# 问题: 如用shell的su命令切换,会遗留一个su本身的进程.
# 最终: 使用perl脚本进行添加和切换操作. 从环境变量User_Id获取用户信息.

use strict;
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;
my $key = 0;

$key = $ENV{'PASSWD'}         if $ENV{'PASSWD'};
$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

unless (getpwuid("$uid")){
  system("/usr/sbin/useradd", "-s", "/bin/false", "-U", "-u $uid", "-m", "docker");
}

my @dirs = ("/redis/logs", "/redis/data", "/redis/conf");
foreach my $dir (@dirs) {
  system("mkdir", "-p", "$dir") unless ( -d $dir );
  if ( -d $dir && (stat($dir))[4] != $uid ){
    system("chown docker.docker -R " . $dir);
  }
}

my $conf = "/redis/conf/redis.conf";
system("cp", "-a", "/example-redis.conf", "$conf") unless ( -f "$conf");
system("sed", "-i", "s/^#requirepass foobared/requirepass $key/", "$conf") if ($key);

system("chmod", "640",    "$conf");
system("chgrp", "docker", "$conf");
system("chmod", "750", "/redis/data");

# 切换当前运行用户,先切GID.
#$GID = $EGID = $gid;
#$UID = $EUID = $uid;
$( = $) = $gid; die "switch gid error\n" if $gid != $( ;
$< = $> = $uid; die "switch uid error\n" if $uid != $< ;

exec(@ARGV);
