#!/usr/bin/bash

# "==========================="
#Author: Sri Karu,karu@synopsys.com
# Script name: vserfver_creation.sh
# created date: 8/5/2020
#echo "==========================="


echo ""

echo "#---------Starting the vserver creation------------------#"

SRC_YAML="/home/ansible/NetappAnsible/vserver_creation_dev"
GLOBAL_VAR="/home/ansible/NetappAnsible/cluster_variables_dev"
SRC_DIR="/home/ansible/NetappAnsible/d2o"
LOG_DIR="/home/ansible/NetappAnsible/vserver_creation_dev/log"
export PATH=/usr/bin:$PATH
DATE=`date +"%H_%M_%m%d%y"`
#echo "Today Date :$DATE"

#echo $SRC_YAML
#echo $GLOBAL_VAR

read -p  "Enter Cluster Name:" cluster
#cluster="$cluster"

read -p "Enter $cluster login:" username
#echo "$username"
#username="$login"
echo  "Enter $username Password: "
read -s password
#read -se "Enter your login passowrd:"  password

read -p "Enter New Vserver Name:" new_vserver

primary_vserver="$cluster"vs1
read -p "Enter Aggregate node name:" node
read -p "Enter Vserver Aggregate Name:" vs_aggregate
read -p "Enter Vserver Partner Aggregate Name:" partner_aggregate

#vs_aggregate="$vs_aggregate"

read -p "Enter Default router address:" gateway
#gateway="$default_router"

echo ""


echo "=======Cluster Input ==========================="
echo "Cluster=$cluster"
echo "username=$username"
echo "new_vserver=$new_vserver"
echo "primary_vserver=$primary_vserver"
echo "Aggregate Node:$node"
echo "Aggregate=$vs_aggregate"
echo "Partner_aggregate=$partner_aggregate"
echo "Default Route=$gateway"

#echo "Primary_vserver=$primary_vserver"
echo "================================================"

while true ; do
read -p "Are these values are Correct ?(Yn/Nn)" yn

   case $yn in
      [Yy]* )  break
       ;;
      [Nn]* ) echo "Please re-enter the value correctly";exit 0
      ;;
      * ) echo "Please answer yes or no.";;
   esac
done


echo ""
echo ""


echo "==========================="
echo "Vserver Creation Menu"
echo "==========================="

echo ""
echo ""

PS3='Please enter your choice :'
COLUMNS=12
options=("Syntax-check-nfsv3"
         "Vserver_creation-nfsv3"
         "Syntax-check-nfsv4"
         "Vserver_creation-nfsv4"
         "Quit" )

select opt in "${options[@]}"
do

   case $opt in

        "Syntax-check-nfsv3")
            ansible-playbook --extra-vars  \
           " cluster=$cluster\
             username=$username
             vserver=$new_vserver\
             vs_aggregate=$vs_aggregate \
             partner_aggregate=$partner_aggregate \
             gateway=$gateway \
             primary_vserver=$primary_vserver" \
             --extra-vars @$GLOBAL_VAR/us01cm_global_variables.yml \
             "$SRC_YAML/us01cm_svm_creation_nfsv3.yml" --syntax-check

             break
             ;;

        "Vserver_creation-nfsv3" )
                 ansible-playbook --extra-vars  \
                "cluster=$cluster\
                 username=$username \
                 password=$password \
                 vserver=$new_vserver\
                 vs_aggregate=$vs_aggregate \
                 partner_aggregate=$partner_aggregate \
                 gateway=$gateway \
                 primary_vserver=$primary_vserver "\
                 --extra-vars @$GLOBAL_VAR/us01cm_global_variables.yml \
                 "$SRC_YAML/us01cm_svm_creation_nfsv3.yml"

                 #"/home/ansible/NetappAnsible/vserver_creation_dev/us01cm_svm_creation_nfsv3.yml"
                 #echo " Vserverver Report generation"
                 #echo $cluster $username $vserver $node
                # $SRC_DIR/vserver_info.py $cluster $username $password $new_vserver $node

                 echo "#-----------Vserver creation Completed--------------------------#"
                 echo "Please create LIF for the newly created the vserver_creation"
                 echo "Please add the Certificate to  newely created Vserver "
                 echo "Please refer the document at TEAM site: General->AdminDocs->Vendors->Netapp->LDAP*.docx"

             break
            ;;

         "Syntax-check-nfsv4")
                 ansible-playbook --extra-vars  \
                "cluster=$cluster\
                 username=$username\
                 password=$password \
                 vserver=$new_vserver\
                 vs_aggregate=$vs_aggregate \
                 partner_aggregate=$partner_aggregate \
                 gateway=$gateway \
                 primary_vserver=$primary_vserver" \
                 --extra-vars @$GLOBAL_VAR/us01cm_global_variables.yml \
                 "$SRC_YAML/us01cm_svm_creation_nfsv4.yml" --syntax-check

           break
           ;;

          "Vserver_creation-nfsv4" )
                 ansible-playbook --extra-vars  \
                "cluster=$cluster\
                 username=$username \
                 password=$password \
                 vserver=$new_vserver\
                 vs_aggregate=$vs_aggregate \
                 partner_aggregate=$partner_aggregate \
                 gateway=$gateway \
                 primary_vserver=$primary_vserver" \
                 --extra-vars @$GLOBAL_VAR/us01cm_global_variables.yml \
                 "$SRC_YAML/us01cm_svm_creation_nfsv4.yml"
                 echo " Vserverver Report generation"
                 #echo $cluster $username $vserver $node
                 $SRC_DIR/vserver_info.py $cluster $username $password $new_vserver $node

                 echo "#-----------Vserver creation Completed--------------------------#"
                 echo "Please create LIF for the newly created the vserver_creation"
                 echo "Please add the Certificate to  newely created Vserver "
                 echo "Please refer the document at TEAM site: General->AdminDocs->Vendors->Netapp->LDAP*.docx"
            #
             break
           ;;

        "Quit")
          break
          ;;
        * ) echo "Option Invalid, select betwee (1-5)."
          ;;
    esac
done




#echo "#------------------------------------------#"
#echo "Thanks for using Vserver Creation Wrapper  #"
#echo "#------------------------------------------#"