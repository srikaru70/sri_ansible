#!/usr/local/bin/python

print ( "#-----------------------Usage(Default Terminal): ./vserver_info.py <cluster_name> <username> <password> <vserver> <node_name> --------------------#")
import sys
import os
import paramiko
import getpass
import time
import socket
import smtplib
from email.mime.text import MIMEText
hostname = socket.gethostname()


#print ( "#-----------------------Usage(Default Terminal): ./vserver_info.py <cluster_name> <username> <password> <node_name> <vserver>---------------------#")
 #   print ( "#-----------------------Usage(Mac_OS): ./d2o_docrea.py <cluster_name> <\"node_name\"> not <svm_name>----------------------------#")
#print ( "#--------------------Use your synopsys login to generate the report---------------------------------------------------------#")
#--------------------------------------------------------------------------------------------------
## check the sjc-nacmaster is executable host

#exe_host ="us01nasadmin03"

#if hostname != exe_host  :
#    print ( "Run the program on 'exe_host'" )
#    exit()
#else:

#    print ( "Please wait..........")

#username = getpass.getuser()
#sender_addr = ((username) + "@synopsys")
#RSA_LOC="/root/.ssh/id_rsa"
Report_dir="/home/ansible/NetappAnsible/d2o/report/"
##Windows_path= r"\\sjc5b-netapp-ns\dfs\grc-mapping\d2o\report"
today_date = time.strftime("%d %b %Y  %H:%M:%S")
date = time.strftime("%H%M_%d%b%Y")
#report_name = (username +"_"+date+".txt")
##r_name = (Report_dir +"/"+username +"_"+date+".txt")
##message = (Report_dir+"/"+"message"+".txt")
#
###Input DATA#####
try:
#    script_name = sys.argv[0]
    cluster = sys.argv[1]
    username = sys.argv[2]
   # username = ("synopsys"+"\\"+login)
    password = sys.argv[3]
    vserver = sys.argv[4]
    node_list = sys.argv[5]

    print ( "Cluster"+":"+cluster)
    print ( "Username"+":"+username)
    print ( "Vserver"+":"+vserver)
    print ( "Node"+":"+node_list)
 #   report_name = (username +"_"+node_list+"_"+"report_"+date+".txt")
    r_name = (Report_dir +"/"+username +"_"+date+".txt")
  #  r_name = (Report_dir +"/"+report_name)
    #r_name = ("sri" +"_"+date+".txt")
    #print ( "Script Name:"+""+script_name)

except IndexError :
    print ( "#-----------------------Usage(Default Terminal): ./vserver_info.py <cluster_name> <username> <password>  <vserver> <node_name>---------------------#")
 #   print ( "#-----------------------Usage(Mac_OS): ./d2o_docrea.py <cluster_name> <\"node_name\"> not <svm_name>----------------------------#")
    print ( "#-----------------------Use your synopsys login to generate the report---------------------------------------------------------#")
    exit()
##SSH connection###
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
paramiko.util.log_to_file("filename.log")
client_conn = client.connect (cluster,port=22,username=username,password=password,look_for_keys=False)
#print ("Node name(list):"+node_list)
#username = ("synopsys"+"\\"+username)
#username = "admin"
#print (username)
#print ("Enter your 'username' account password")
#print ("Enter your " + username + "  account password:")
#password = getpass.getpass()

print ( "#"*100)

def function_title (title):
      # r_name = ("sri" +"_"+date+".txt")
       f=open(r_name, "a")
       f.write(str(title) +'\n')

def function_report (output):
      # file = ("sri.txt" +"_"+date)
      # r_name = ("sri" +"_"+date+".txt")
       f=open(r_name, "a")
       f.write(str(output) +'\n')
       line = "------------------------------------------------------------------------------------------"
       f.write(line +'\n')



###with Node List
def filerconnect_withnode (cluster,command):
#  print ( cluster )
 # print ( username )
 # print ( password )
#  client_conn = client.connect (cluster,port=22,username=username,password=password)
  node_input = "-node"+" "+node_list
  vserver_input = "-vserver"+ " "+vserver
  #username = "-username"+ " " +username
  command = command +" "+node_input +" " + vserver_input
  #print (command)
  stdin, stdout, stderr = client.exec_command(command)
  output = stdout.read().decode('utf-8')
  #print (output)
  function_report(output)
 # client.close()



###Without node list
def filerconnect_withoutnode (cluster,command):
  #print ( cluster )
  #print ( username )
  #print ( password )
  #client_conn = client.connect (cluster,port=22,username=username,password=password)
  #node_input = node_list
  command = command +" " +vserver
  stdin, stdout, stderr = client.exec_command(command)
  output = stdout.read().decode('utf-8')
  function_report(output)
  #client.close()




#-------------------------------------------------------------------------------
f=open(r_name, "w")
#f=open("Report_dir/"r_name, "w")
heading = ("Vserver Information: Report is created for the nodes "+ node_list  + " by " + username +"  on " +  today_date)
print(heading)
f.write(heading + '\n')
f.write("_________________________________________________________________________________________________" + '\n')
f.close()

###Report Generation###




title = "1. Vserver Information:"
function_title (title)
#print (vserver)
command = "rows 0 ;vserver show -fields vserver,type,rootvolume,ldap-client,allowed-protocols ,aggregate,type -vserver"
filerconnect_withoutnode(cluster,command)
print ("1.Vserver Information:                          Completed")


title = "2.Vserver DNS server Information:"
function_title (title)
command = "rows 0 ; services dns show -fields domains,name-servers -vserver"
filerconnect_withoutnode (cluster,command)
print ("2.Vserver DNS server Information:               Completed")


title = "3.Vserver NFS Information:"
function_title (title)
command = "rows 0 ;set advanced ; vserver nfs show -vserver"
filerconnect_withoutnode (cluster,command)
print ("3.Vserver NFS Information:                      Completed")

title = "4.Vserver Export poliy information:"
function_title (title)
command = "rows 0; export-policy show -policyname * -vserver"
filerconnect_withoutnode (cluster,command)
command = "rows 0; export-policy rule show -fields clientmatch,rw,ro,superuser -vserver"
filerconnect_withoutnode (cluster,command)
print ("4.Vserver Expoprt poliy information:            Completed")

title = "5.Vserver NS-SWITCH Information:"
function_title (title)
command = "rows 0; services ns-switch show -database group,hosts,passwd -vserver"
filerconnect_withoutnode (cluster,command)
print ("5.Vserver NS-SWITCH Information:                Completed")

title = "6.Vserver Default Router Information:"
function_title (title)
command = "rows 0;route show -fields destination,gateway,metric -vserver"
filerconnect_withoutnode (cluster,command)
print ("6.Vserver Default Router Information:           Completed")

title = "7.Vserver Name-Service Cache Information:"
function_title (title)
command = "set diag ;rows 0; name-service cache unix-user settings show -vserver "
filerconnect_withoutnode (cluster,command)
print ("7.Vserver Name-Service Cache Information:       Completed")


title = "8.Vserver LDAP Information:"
function_title (title)
command = "rows 0; name-service ldap show -fields client-config -vserver"
filerconnect_withoutnode (cluster,command)
command = "rows 0; ldap client schema show -schema SNPS -vserver"
filerconnect_withoutnode (cluster,command)
command = "rows 0;set advanced ;ldap client show -fields client-config ,ldap-servers,base-dn,user-dn,bind-dn,schema,base-scope,group-dn,use-start-tls,group-membership-filter -vserver"
filerconnect_withoutnode (cluster,command)
print ("8.Vserver LDAP Information:                     Completed")

title = "9.Vserver Snapshot Policy Information:"
function_title (title)
command = "set admin ;rows 0 ; snapshot policy show -vserver"
filerconnect_withoutnode (cluster,command)
print ("9.Vserver Snapshot Policy Information:          Completed")

title = "10.Test User and Group:"
function_title (title)
command = "rows 0;set diag ; secd authentication translate -unix-user-name admin"
filerconnect_withnode (cluster,command)

command = "rows 0;set diag ; secd authentication translate -unix-user-name regress "
filerconnect_withnode (cluster,command)

command = "rows 0;set diag ; secd authentication translate -unix-group-name essm "
filerconnect_withnode (cluster,command)
print ("10.Test User and Group:                         Completed")
filerconnect_withnode (cluster,command)

title = "11. Verify the group listing of a user:"
function_title (title)
command = "rows 0;set advanced;getxxbyyy getgrlist -username username"
filerconnect_withnode (cluster,command)
print ("11.Verify the group listing of a user:          Completed")


title = "12.Test withdrawn user:"
function_title (title)
command = "rows 0;set diag ; secd authentication translate -unix-user-name rwu "
filerconnect_withnode (cluster,command)
print ( "12.Test withdrawn user:                         Completed")


title = " 13 LS mirror information"
function_title (title)
command = "snapmirror show -vserver "

filerconnect_withoutnode (cluster,command)
print ("13.LS mirror information                        Completed")

client.close()
#print("#--------------------------------------------------------------------------------------#")
print ( "#"*100)

#print (r_name)
print ( "Report generation is completed.")
print ( "Report Name:"+ r_name)

#Sprint ( "Report is avaialbe at:" + Windows_path)
print ( "#"*100)
#print("#--------------------------------------------------------------------------------------#")

####Sending email notification#####
#sender_addr = ((username) + "@synopsys.com")
#receivers = 'skarupat@cisco.com'
#receivers = sender_addr
#f=open("message.txt", "w")
#f=open(message, "w")
#f.write("Report Name:"+ report_name +'\n')
#f.write("Report Location: " "\\\sjc5b-netapp-ns\dfs\grc-mapping\d2o\\report"+'\n')
#f.close()
###EMAIL Notification####
#with open("message.txt") as f:
#with open(message) as f:

 #  msg = MIMEText(f.read())
  # msg['Subject'] = 'D2O report ready'
  # msg['From'] = sender_addr
  # msg['To'] = receivers

# Send the message via our own SMTP server.
#s = smtplib.SMTP('localhost')
#s.send_message(msg)
#s.quit()

#print ("Email notification has been sent to your address:" +sender_addr)
#os.remove(message) ### remove message file
