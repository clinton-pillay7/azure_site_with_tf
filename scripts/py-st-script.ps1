$flaskappurl = "https://github.com/SashiDuratech/flaskhelloworld/raw/master/app.py"
$flaskapp = "C:\users\public\flaskapp\main.py"
New-Item -name flaskapp -ItemType directory -Path "C:\users\public\"
Invoke-WebRequest $flaskappurl -OutFile "C:\users\public\flaskapp\main.py"
pip install flask
python $flaskapp