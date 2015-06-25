
@echo off

echo.
echo ++++++++++++++++ masm file: %1 +++++++++++
tools\masm.exe %1;


echo.
echo ++++++++++++++++ link file: %2 +++++++++++
tools\link.exe %2;
