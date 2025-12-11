sudo cp systemd/cryptoserver.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cryptoserver
sudo systemctl start cryptoserver

sudo journalctl -f cryptoserver