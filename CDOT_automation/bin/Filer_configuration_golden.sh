#!/bin/bash
# A menu driven shell script Cluster configuration
#Author : Sri Karu, karu@synopsys.com

## ----------------------------------
# Step #1: Define variables
# ----------------------------------
SRC_YAML="/home/ansible/NetappAnsible/CDOT_automation/cluster_config"
GLOBAL_VAR="/home/ansible/NetappAnsible/CDOT_automation/cluster_variable"
SRC_DIR="/home/ansible/NetappAnsible/CDOT_automation/d2o/bin"
LOG_DIR="/home/ansible/NetappAnsible/CDOT_automation/log"
export PATH=/usr/bin:$PATH
DATE=`date +"%H_%M_%m%d%y"`
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# ----------------------------------
# Step #2: User defined function
# ----------------------------------
Cluster_login() {

echo "Enter Cluster Credentials:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
read -p  "Enter Cluster Name:" cluster
#cluster="$cluster"

read -p "Enter $cluster login:" username

echo  "Enter $username Password: "
read -s password
#
echo "~~~~~~~~~~~~~Cluster Input ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "Cluster=$cluster" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "username=$username" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}


vserver_input(){
echo ""

echo "Enter New Vserver Details:"
echo ""
read -p "Enter Primary vserver:" primary_vserver
read -p "Enter New Vserver Name:" new_vserver
read -p "Enter Aggregate Node name:" node
read -p "Enter Vserver Aggregate Name:" vs_aggregate
read -p "Enter Vserver Partner Aggregate Name:" partner_aggregate
read -p "Enter Default router address:" gateway
#primary_vserver="$cluster"vs1

echo ""
echo "~~~~~~~~~~Vserver Details~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Cluster=$cluster"
echo "username=$username"
echo "primary_vserver=$primary_vserver" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "new_vserver=$new_vserver" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "Aggregate Node:$node" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "Aggregate=$vs_aggregate" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "Partner_aggregate=$partner_aggregate" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "Default Route=$gateway" | tee -a $LOG_DIR/vserver_create.log_$DATE
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}


confirm_input(){

          read -p "Are these values are Correct ?(Yn/Nn)" yn

          while true ;

          do
    #read -p "Are these values are Correct ?(Yn/Nn)" yn
            case $yn in
            [Yy]* )  break
            ;;
         #  [Nn]* ) echo "Please re-enter the value correctly";exit 0
            [Nn]* ) echo "" ; \
                    echo "Please re-enter the values correctly!!!!"; \
                    echo ""
                    exit 0
            ;;
           * ) echo "Please answer yes or no."
           esac
done
}



vserver_creation_nfsv3() {
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
                 echo " Vserver Information Report Generation"
                 $SRC_DIR/ansible_report.py $cluster $username $password $new_vserver $node
                 break
}

vserver_creation-nfsv4(){
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
                 echo "#-----------Vserver creation Completed--------------------------#"
                 echo " Vserver Information Report Generation"
                 $SRC_DIR/ansible_report.py $cluster $username $password $new_vserver $node

}

Info (){
                 echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                 echo "Please create LIF for the newly created the Vserver"
                 echo "Please add the Certificate to  newely created Vserver "
                 echo "Please refer the document at TEAM site: General->AdminDocs->Vendors->Netapp->LDAP*.docx"
                 echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
 }




confirm_input_aggregate(){
       if [ -f "$GLOBAL_VAR/"$cluster"_aggregate_configuration.yml" ] ; then

           cat $GLOBAL_VAR/"$cluster"_aggregate_configuration.yml
        else
           echo "Please update the Control file at $GLOBAL_VAR/"$cluster"_aggregate_configuration.yml"
           exit 0
        fi
}





Aggregate_Creation(){

 #   echo "test"
#    ansible-playbook --extra-vars="@$GLOBAL_VAR/"$cluster"_aggregate_configuration.yml" $SRC_YAML/Cluster_config.yml -t Aggregate_create
     ansible-playbook --extra-vars \
     "cluster=$cluster \
     username=$username \
     password=$password " \
     --extra-vars @$GLOBAL_VAR/"$cluster"_aggregate_configuration.yml \
     $SRC_YAML/Cluster_config.yml -t Aggregate_create -vvv
}


confirm_input_sp(){
       if [ -f "$GLOBAL_VAR/"$cluster"_SP_Configuration.yml" ] ; then

           cat $GLOBAL_VAR/"$cluster"_SP_Configuration.yml
        else
           echo "Please update the Control file at $GLOBAL_VAR/"$cluster"_SP_Configuration.yml"
           exit 0
        fi
}

SP_creation(){
   # ansible-playbook --extra-vars="@$GLOBAL_VAR/SP_Configuration.yml" $SRC_YAML/SP_create.yml --syntax-check
    ansible-playbook --extra-vars \
    "cluster=$cluster \
     username=$username \
     password=$password"  \
     --extra-vars @$GLOBAL_VAR/"$cluster"_SP_Configuration.yml \
     $SRC_YAML/Cluster_config.yml -t SP_Configuration
}


# function to display menus
show_menus() {
    clear
    echo ""
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo " Welcome to Netapp filer Ansible Automation!"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo " FILER Config : M A I N - M E N U"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "1. Vserver_creation-nfsv3"
    echo "2. Vserver_creation-nfsv4"
    echo "3. LS_Mirror_Creation "
    echo "4. Aggregate_Creation"
    echo "5. LIF_Creation"
    echo "6. SP_configuration"
    echo "7. Quit"
}

read_options(){
    local choice
    read -p "Enter choice [ 1 - 6] " choice
    case $choice in
        1) Vserver_creation-nfsv3 ;;
        2) Vserver_creation-nfsv4 ;;
        3) LS_Mirror_Creation ;;
        4) Aggregate_Create ;;
        5) LIF_Creation ;;
        6) SP_configuration ;;
        7) echo "" ;echo "~~~~~~~~~~~Thanks for using Filer Automation Script !!"; \
           echo "" ;exit ;;
        *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
}

Vserver_creation-nfsv3(){
    echo -e "~~~~~~~~Welcome to Nfsv3~~~~~~~~~~~"
    Cluster_login
    vserver_input
    confirm_input
   # cluster_input_variables
    vserver_creation_nfsv3
    break
}

Vserver_creation-nfsv4(){
    echo "Welcome to Nfsv4"
    echo -e "~~~~~~~~Welcome to Nfsv4~~~~~~~~~~~"
    Cluster_login
    vserver_input
   # cluster_input_variables
    #vserver_creation_nfsv4
    info
    break
}

LS_Mirror_Creation(){
   echo -e "Coming Soon!"
   sleep 30
   Cluster_login
   confirm_input
   #Cluster_login
   Info
   break
}

Aggregate_Create(){

    Cluster_login
    confirm_input_aggregate
    confirm_input
    Aggregate_Creation
    break
}

LIF_Creation(){
    echo "Coming Soon!"
    sleep 15
    confirm_input
    Info
    break
}

SP_configuration(){
    Cluster_login
    confirm_input_sp
    confirm_input
    SP_creation
    #Info
    break
}

####Display the menu#######
while true
do

    show_menus
    read_options
done