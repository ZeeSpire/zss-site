@ECHO OFF 
ECHO =============== Cleaning project ===============
call ./clean.bat
ECHO =============== Commit - Push to master ===============
git add .
git commit -m "Update"
git push
ECHO =============== Finished ===============
