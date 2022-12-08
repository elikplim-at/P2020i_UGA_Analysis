capture veracrypt, dismount drive(H)   // in case it is already mounted (=decrypted)

global location "$encrypted_drive:\"



local dir "$project_folder"  //Location of the encrypted folder

*cd "`dir'"

cd "$ANALYSIS"

*****************************
* Password: QG5yVFU*sh3/     <--- write down here the password in case we forget it
******************************
veracrypt 04_Raw_Data_Ready2, mount drive($encrypted_drive)  //"Where 04_Raw_Data_Ready2" is the encrpypted folder








