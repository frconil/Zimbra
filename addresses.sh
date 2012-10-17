#quick and dirty one line script to automate a dump of addresses from domain.com using zimbra archiving
#addresses have been dumped to addresseslist prior to archiving

cat addresseslist | sed s/@domain.com// | awk '{print "zmmailbox -z -m "$1"@domain.com  getRestURL \"//?fmt=tgz\" > "$1".tgz"}' | sh
