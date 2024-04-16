@REM call run_test.bat 50 50 0 0 case_inc_inc
@REM call run_test.bat 30 30 0 1 case_inc_dec
@REM call run_test.bat 40 40 0 2 case_inc_rand
@REM call run_test.bat 35 35 1 0 case_dec_inc
@REM call run_test.bat 45 45 1 1 case_dec_dec
@REM call run_test.bat 55 55 1 2 case_dec_rand
@REM call run_test.bat 60 60 2 0 case_rand_inc
@REM call run_test.bat 70 70 2 1 case_rand_dec
@REM call run_test.bat 80 80 2 2 case_rand_rand

@REM code to remove all files from directory ../reports/regression_transcript:
del /Q /S "..\reports\regression_transcript\*"
del /Q /S "..\reports\*.txt"

call run_test 50 32 2 2 CASE1 555 cli
call run_test 50 32 2 2 CASE2 732 cli
call run_test 50 32 2 2 CASE3 682 cli
call run_test 50 32 2 2 CASE4 123 cli
call run_test 50 32 2 2 CASE5 456 cli
call run_test 50 32 2 2 CASE6 789 cli
call run_test 120 32 2 2 CASE7 321 cli
call run_test 130 32 2 2 CASE9 987 cli
call run_test 120 32 2 2 CASE10 654 cli