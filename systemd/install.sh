sudo cp systemd/passwordserver.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable passwordserver
sudo systemctl start passwordserver