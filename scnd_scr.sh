#!/bin/bash

echo "=== ТЕСТ 1 ===" # expecting output: there is no such directory
{
    echo "test_folder"   
    echo "10"            
    echo "50"            
} | ./frst_scr.sh

echo ""
echo "=== ТЕСТ 2 ===" #no framed, no files inside
{
    echo "test_folder_2"    
    echo "10"           
    echo "70"            
} | ./frst_scr.sh

echo ""
echo "=== ТЕСТ 3 ===" #no framed files inside
{
    echo "test_folder_3"    
    echo "10"           
    echo "30"          
} | ./frst_scr.sh

echo "=== ТЕСТ 4 ===" #framed, do not need archieve
{
    echo "test_folder_4"   
    echo "15"            
    echo "30"           
} | ./frst_scr.sh

echo "=== ТЕСТ 5 ===" #framed, need archieve
{
    echo "test_folder_5"    
    echo "15"            
    echo "30"            
} | ./frst_scr.sh
