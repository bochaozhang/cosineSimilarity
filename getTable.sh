# Read database and export tables for desired features: tissue, subtype, etc.
# instanceTable.tsv: number of instances in each clone in each feature
# sampleTable.tsv: number of samples in each clone in each feature

echo -n "Enter database and press [Enter]:"
read db_name
echo -n "Enter subject and press [Enter]:"
read subject
echo -n "Enter feature and press [Enter]:"
read feature

subject_id=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select id from subjects where identifier='$subject'")

features=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select distinct $feature from samples where subject_id=$subject_id")
unique_features=$(echo "${features[@]}" | tr '\n' ' ')
echo "Features: $unique_features"

echo -e "\t${unique_features[@]}" | tr ' ' '\t' > instanceTable.tsv
echo -e "\t${unique_features[@]}" | tr ' ' '\t' > sampleTable.tsv

clones=()
while read -r output_line; do
    clones+=($output_line)
done < <(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select id from clones where subject_id=$subject_id and functional=1")
echo "${#clones[@]} clones featched"

declare -A feature_samples
for feat in ${unique_features}; do
    sample_ids=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select distinct id from samples where $feature='$feat' and subject_id=$subject_id")
    unique_sample_ids=$(echo "${sample_ids[@]}" | tr '\n' ',')
    feature_samples[$feat]=${unique_sample_ids::-1}
done

for clone in ${clones[@]}; do
    seq_counts=()
    sample_counts=()
    i=0
    for feat in ${unique_features[@]}; do
        sample_group=$(echo "${feature_samples[$feat]}" | tr ' ' ',')
        seq_counts[i]=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select count(*) from sequences where clone_id=$clone and functional=1 and sample_id in ($sample_group)")
        sample_counts[i]=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select count(distinct sample_id) from sequences where clone_id=$clone and functional=1 and sample_id in ($sample_group) ")
        i+=1
    done
    for n in ${seq_counts[@]}; do
###############################
        if (($n>0)); then      # <------change minimum threshold here
###############################
            echo -e "$clone\t${seq_counts[@]}" | tr ' ' '\t' >> instanceTable.tsv
            echo -e "$clone\t${sample_counts[@]}" | tr ' ' '\t' >> sampleTable.tsv
            break
        fi
    done 
done
