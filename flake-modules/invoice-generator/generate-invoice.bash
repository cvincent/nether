cd /backup/chris/Invoices/Generate

business=$1
bill_to=$2
client_name=$3
hours=$4
month=$5
date=$(date "+%b %-d, %Y")

last_invoice_num=$(cat ./${business}-last-invoice-num)
rate=$(cat ./${business}-rate)
from=$(cat ./${business}-from)
to=$(cat ./${business}-to)
to_first_name=$(cat ./${business}-to-first-name)

let next_invoice_num="$last_invoice_num + 1"
let total="$rate * $hours"
total=$(printf "%'.0f" $total)

if [[ -z "$month" ]]; then
  month=$(date "+%b %Y")
fi

from_email=$(cat ./${business}-from | sed "s/.*<\(.\+\)>/\1/")

echo "Generate $business invoice #$next_invoice_num for $bill_to in $month; $hours hours at \$$rate/hr, total \$$total."

cat ./${business}-template.tex |
  sed "
    s/###BILL_TO###/$bill_to/g;
    s/###INVOICE_NUM###/$next_invoice_num/g;
    s/###DATE###/$date/g;
    s/###TOTAL###/$total/g;
    s/###FROM###/$from_email/g;
    s/###MONTH###/$month/g;
    s/###CLIENT_NAME###/$client_name/g;
    s/###HOURS###/$hours/g;
    s/###RATE###/$rate/g
  " > ./${business}-rendered.tex

xelatex ./${business}-rendered.tex -o ./${business}-invoice.pdf > /dev/null

invoice_encoded=$(base64 ./${business}-rendered.pdf)

cat <<-EOF > ./email.mail
Content-Type: multipart/mixed; boundary=19032019ABCDE
X-Attached: Invoice-${next_invoice_num}.pdf
Mime-Version: 1.0
From: $from
To: $to
Subject: Invoice for $month

--19032019ABCDE
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=utf-8

Hey $to_first_name,

Attached is my invoice for last month.

Thanks!

Chris

--19032019ABCDE
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=Invoice-${next_invoice_num}.pdf
Content-Type: application/pdf; name=Invoice-${next_invoice_num}.pdf

$invoice_encoded
--19032019ABCDE--
EOF

zathura ./${business}-rendered.pdf

read -p "Look good? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cat ./email.mail | msmtp --host="127.0.0.1" --port=1025 --auth=plain --user="$from_email" --passwordeval="cat /backup/chris/Invoices/Generate/${business}-pass" --from="$from_email" $to
  rm ./email.mail
  mv ./${business}-rendered.pdf "../$bill_to/Invoice-${next_invoice_num}.pdf"
  echo $next_invoice_num > ./${business}-last-invoice-num
fi
