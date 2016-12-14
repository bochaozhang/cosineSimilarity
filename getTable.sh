# Read database and export table for desired features: tissue, subtype, etc.

echo -n "Enter subject and press [Enter]:"
read subject
echo -n "Enter feature and press [Enter]:"
read feature

subject_id=$(mysql -h clash.biomed.drexel.edu -u bzhang --password=zbczbc --database=lp11 -N -B -e "select id from subjects where identifier='$subject'")
echo "${subject_id}"

features=()
while read -r output_line; do
    features+=("$output_line")
done < <(mysql -h clash.biomed.drexel.edu -u bzhang --password=zbczbc --database=lp11 -N -B -e "select $feature from samples where subject_id=$subject_id")

echo "There are ${#features[@]} lines returned"
