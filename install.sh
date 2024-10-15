[ ! -d /root/backup ] && mkdir /root/backup
cp -r /root/verifier/configs /root/backup/carv

cd ~
rm -r verifier
git clone https://github.com/carv-protocol/verifier.git
cd verifier
make build

cp -r /root/backup/carv/configs /root/verifier
