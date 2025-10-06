mkdir test_folder_2
mkdir test_folder_3
dd if=/dev/urandom of=test_folder_3/1mb_file.txt bs=1M count=1
dd if=/dev/urandom of=test_folder_3/1rmb_file.txt bs=1M count=1
mkdir test_folder_4
mkdir test_folder_5
mkdir test_folder_6
{
    echo "test_folder_4"    
    echo "10"            
    echo "30"           
} | ./frst_scr.sh
{
    echo "test_folder_5"    
    echo "10"            
    echo "30"            
} | ./frst_scr.sh
dd if=/dev/urandom of=test_folder_5/1mb_file.txt bs=1M count=1
dd if=/dev/urandom of=test_folder_5/2mb_file.txt bs=1M count=2
dd if=/dev/urandom of=test_folder_5/1rmb_file.txt bs=1M count=1
dd if=/dev/urandom of=test_folder_5/3mb_file.txt bs=1M count=3
