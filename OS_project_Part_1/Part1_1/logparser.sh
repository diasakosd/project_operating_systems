#Γρηγόρης Δελημπαλταδάκης, 1084647
#ΔΙΑΣΑΚΟΣ ΔΑΜΙΑΝΟΣ, 1084632
#ΑΛΚΙΒΙΑΔΗΣ ΔΑΣΚΑΛΑΚΗΣ, 1084673
#ΡΑΙΚΟΣ ΙΑΣΩΝ, 1084552

shopt -s extglob

function mining_usernames()
{
awk '{print $3}' $1 | sort | uniq -c 
}

function count_browsers()
{
awk 'match($0,"Mozilla") {print "Mozilla";} match($0,"Edg") {print "Edg";} match($0,"Safari") {print "Safari";} match($0,"Chrome") {print "Chrome";}' $1 | sort | uniq -c | perl -ane 'print "$F[1] $F[0]\n"'
}

case "$1|$2|$3" in
"||")
echo "1084647|1084632|1084673|1084552"
;;

!(*.log)"|"*"|"*)
echo "Wrong File Argument!"
;;

*.log"||")
cat $1
echo
;;

*.log"|--usrid|")
mining_usernames $1
;;

*.log"|--usrid|"*)
awk -v user_id="$3" 'user_id~$3 {print}' $1
;;

*.log"|-method|GET" | *.log"|-method|POST")
if [[ "$3" = "GET" ]]
then
sed -n '/GET/p' $1
else
sed -n '/POST/p' $1
fi

echo
;;

*.log"|-method|"*)
echo "Wrong Method Name!"
;;

*.log"|--servprot|IPv4" | *.log"|--servprot|IPv6")
if [[ "$3" = "IPv4" ]]
then
sed -n '/127.0.0.1/p' $1
else
sed -n '/::1/p' $1
fi

echo
;;

*.log"|--servprot|"*)
echo "Wrong Network Protocol!"
;;

*.log"|--browsers|")
count_browsers $1
;;

*.log"|--datum|Jan" | *.log"|--datum|Feb" | *.log"|--datum|Mar" | *.log"|--datum|Apr" | *.log"|--datum|May" | *.log"|--datum|Jun" | *.log"|--datum|Jul" | *.log"|--datum|Aug" | *.log"|--datum|Sep" | *.log"|--datum|Oct" | *.log"|--datum|Nov" | *.log"|--datum|Dec")
awk -v month="$3" '$0~month {print}' $1
;;

*.log"|--datum|"*)
echo "Wrong Date!"
;;

*)
echo -e "Wrong input!\n\nCheck if the arguments are correct."
;;
esac