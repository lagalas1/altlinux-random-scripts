#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Запуск от root"
    exit 1
fi
cd "$(dirname "$0")"
chmod +x uninstall.sh &&
    ./uninstall.sh
if [[ $? != 0 ]]; then
    echo "Скрипт на удаление не найден"
    exit 1
fi
apt-get update
apt-get install pcsc-tools -y
rm -rf /opt/cprocsp/
rm -rf /var/opt/cprocsp/
apt-get remove -y ifcplugin --purge
rm -rf /etc/ifc.cfg
apt-get install --reinstall -y cryptopro-preinstall
apt-get install ./lsb-cprocsp-base-5.0.13000-7.noarch.rpm ./lsb-cprocsp-rdr-64-5.0.13000-7.x86_64.rpm ./lsb-cprocsp-kc1-64-5.0.13000-7.x86_64.rpm ./lsb-cprocsp-capilite-64-5.0.13000-7.x86_64.rpm ./cprocsp-curl-64-5.0.13000-7.x86_64.rpm ./lsb-cprocsp-ca-certs-5.0.13000-7.noarch.rpm ./cprocsp-rdr-gui-gtk-64-5.0.13000-7.x86_64.rpm ./cprocsp-cptools-gtk-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-pcsc-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-emv-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-inpaspot-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-kst-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-mskey-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-novacard-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-edoc-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-rutoken-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-jacarta-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-cloud-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-cpfkc-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-infocrypt-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-rosan-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-cryptoki-64-5.0.13000-7.x86_64.rpm ./cprocsp-rdr-rustoken-64-5.0.13000-7.x86_64.rpm ./cprocsp-pki-cades-64-2.0.15400-1.amd64.rpm ./cprocsp-pki-plugin-64-2.0.15400-1.amd64.rpm ./cprocsp-pki-phpcades-2.0.15400-1.noarch.rpm ./lsb-cprocsp-pkcs11-64-5.0.13000-7.x86_64.rpm ./lsb-cprocsp-import-ca-certs-5.0.13000-7.noarch.rpm

if [[ $? == 0 ]]; then
    echo -e "\033[32m CryptoPro установлен \033[0m"
else
    echo -e "\033[31m Произошла ошибка в процессе установки CryptoPro\033[0m"
    exit 1
fi

apt-get install -y chromium-gost
apt-get install ./IFCPlugin-x86_64.rpm
apt-get install -y token-manager

#Выдача прав
chown -R root /var/opt/cprocsp/tmp
chmod -R a+rw /var/opt/cprocsp/tmp

#Запуск демона
systemctl enable pcscd --now

varS=$(ls /opt/cprocsp/lib/amd64/ | grep libcppkcs11.so.4.0.*)
ln -s /opt/cprocsp/lib/amd64/$varS /usr/lib/mozilla/plugins/lib/libcppkcs11.so
ln -s /etc/opt/chrome/native-messaging-hosts/ru.rtlabs.ifcplugin.json /etc/chromium/native-messaging-hosts/

cat >>/opt/textcpro.txt <<EOF

    {
        name = "CPPKCS11_2001";
        alias = "CPPKCS11_2001";
        type = "pkcs11";
        alg = "gost2001";
        model = "CPPKCS 3";
        lib_linux = "/opt/cprocsp/lib/amd64/libcppkcs11.so";
    },
    {
        name = "CPPKCS11_2012_256";
        alias = "CPPKCS11_2012_256";
        type = "pkcs11";
        alg = "gost2012_256";
        model = "CPPKCS 3";
        lib_linux = "/opt/cprocsp/lib/amd64/libcppkcs11.so";
    },
    {
        name = "CPPKCS11_2012_512";
        alias = "CPPKCS11_2012_512";
        type = "pkcs11";
        alg = "gost2012_512";
        model = "CPPKCS 3";
        lib_linux = "/opt/cprocsp/lib/amd64/libcppkcs11.so";
    },

EOF

sed -i '11r /opt/textcpro.txt' /etc/ifc.cfg
rm -f /opt/textcpro.txt

ln -s /opt/cprocsp/bin/amd64/certmgr /usr/bin/
ln -s /opt/cprocsp/bin/amd64/csptestf /usr/bin/
ln -s /opt/cprocsp/sbin/amd64/cpconfig /usr/sbin/
echo "Симлинки созданы"
/opt/cprocsp/bin/amd64/certmgr -install -store mRoot -file mincifr.cer &&
    /opt/cprocsp/bin/amd64/certmgr -install -store mRoot -file russian_trusted_root_ca_pem.crt &&
    /opt/cprocsp/bin/amd64/certmgr -install -store mRoot -file UFK2022.cer &&
    /opt/cprocsp/bin/amd64/certmgr -install -store mRoot -file UFK2023.cer &&
    /opt/cprocsp/bin/amd64/certmgr -install -store mRoot -file UFK2024.cer &&
    cp mincifr.cer /usr/share/pki/ca-trust-source/anchors/ &&
    cp russian_trusted_root_ca_pem.crt /usr/share/pki/ca-trust-source/anchors/ &&
    cp UFK2022.cer /usr/share/pki/ca-trust-source/anchors/ &&
    cp UFK2023.cer /usr/share/pki/ca-trust-source/anchors/ &&
    cp UFK2024.cer /usr/share/pki/ca-trust-source/anchors/ &&
    update-ca-trust

/opt/cprocsp/sbin/amd64/cpconfig -ini '\Cryptography\OID\EncodingType 0\CertDllCreateCertificateChainEngine\Config' -add long ChainUrlRetrievalTimeoutMilliseconds 60000 &&
    /opt/cprocsp/sbin/amd64/cpconfig -ini '\Cryptography\OID\EncodingType 0\CertDllCreateCertificateChainEngine\Config' -add long ChainRevAccumulativeUrlRetrievalTimeoutMilliseconds 60000 &&
    echo "Увеличено время для скачивания crl файлов"

if [[ $? == 0 ]]; then
    echo -e "\033[32m Корневые сертификаты установлены \033[0m"
else
    echo -e "\033[31m Произошла ошибка при установке корневых сертификатов, изучите сообщения выше для анализа\033[0m"
fi
while true; do
    echo "Текущая лицензия:"
    cpconfig -license -view
    read -r -p "Введите лиц. ключ или оставьте поле пустым чтобы завершить установку: " LICENCE
    case $LICENCE in
    "") break ;;
    *) cpconfig -license -set "$LICENCE" ;;
    esac
done

if ! rpm -q jacartauc-3.3.3.3763-1.x86_64 &>/dev/null; then
    chmod +x install_jacarta.sh
    ./install_jacarta.sh
fi
