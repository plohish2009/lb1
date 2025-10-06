#!/bin/bash

echo "=== TEST 1 ===" # expecting output: there is no such directory
{
    echo "test_folder"   
    echo "10"            
    echo "50"            
} | ./frst_scr.sh
echo ""
echo "=== TEST 2 ===" # Negative disk capacity
{
    echo "test_folder_2"
    echo "-5"
} | ./frst_scr.sh
echo ""

echo "=== TEST 3 ===" #no framed, no files inside
{
    echo "test_folder_2"    
    echo "10"           
    echo "70"            
} | ./frst_scr.sh

echo ""
echo "=== TEST 4 ===" #no framed files inside
{
    echo "test_folder_3"    
    echo "10"           
    echo "30"          
} | ./frst_scr.sh

echo "=== TEST 5 ===" #framed, do not need archieve
{
    echo "test_folder_4"   
    echo "15"            
    echo "30"           
} | ./frst_scr.sh

echo "=== TEST 6 ===" #framed, need archieve
{
    echo "test_folder_5"    
    echo "15"            
    echo "30"            
} | ./frst_scr.sh

echo "=== TEST 7 ===" #trying to frame on very big number (more than we have)
{
    echo "test_folder_6"    
    echo "400000"            
    echo "30"            
} | ./frst_scr.sh

echo "=== TEST 8 ===" #framed,  Limit <  0%
{
    echo "test_folder_4"
    echo "-90"
} | ./frst_scr.sh

echo ""
echo "=== TEST 9 ===" #framed, Limit > 100% 
{
    echo "test_folder_4"
    echo "150"
} | ./frst_scr.sh
