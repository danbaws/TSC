::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
::vsim -gui -do run.do %1
::vsim -c -do run.do

vsim -c -do "do run.do %1 %2 %3 %4 %5"
:: vsim -pvalue WRITE_NR

cd ../tools
:: tema: o regresie test, fopen(fisier.txt) pentru... o cer cuiva ca am uitat