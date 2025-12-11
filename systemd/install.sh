sudo cp cryptoserver.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cryptoserver
sudo systemctl start cryptoserver

sudo journalctl -u cryptoserver -f
