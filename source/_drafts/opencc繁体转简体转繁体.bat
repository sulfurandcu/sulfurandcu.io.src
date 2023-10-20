for /r %%i in (*.md) do ( D:\develop.r.1\opencc\bin\opencc.exe -c D:\develop.r.1\opencc\bin\t2s.json -i "%%i" -o "%%i" )
for /r %%i in (*.md) do ( D:\develop.r.1\opencc\bin\opencc.exe -c D:\develop.r.1\opencc\bin\s2t.json -i "%%i" -o "%%i" )
