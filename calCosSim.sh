# get input parameters
while getopts ":d:s:f:t:" opt; do
  case $opt in
    d) db_name=$OPTARG;;
    s) subject=$OPTARG;;
    f) feature=$OPTARG;;     
    t) size_threshold=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1;;
  esac
done
echo -e "database: $db_name\nsubject: $subject\nlower clone size bound: $size_threshold"

# get all features
features=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select distinct $feature from samples left join subjects on samples.subject_id = subjects.id where subjects.identifier='$subject'")
unique_features=$(echo "${features[@]}" | tr '\n' ' ')
echo "$feature: $unique_features"

# print out table header
echo -e "clone_id\t${unique_features[@]}" | tr ' ' '\t' > instanceTable.tsv
echo -e "clone_id\t${unique_features[@]}" | tr ' ' '\t' > sampleTable.tsv

# Get qualified clones
qualified_clones=()
declare -A feature_samples  # save feature sample groups for later
for feat in ${unique_features}; do
	# Get sample ids
	sample_id=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select samples.id from subjects right join samples on subjects.id = samples.subject_id where subjects.identifier='$subject' and samples.$feature='$feat'")
	sample_id=$(echo "${sample_id[@]}" | tr '\n' ',')
	sample_id=${sample_id::-1}
    feature_samples[$feat]=$sample_id

    # Filter clones by size (instance)
	clones=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select clone_id,count(distinct seq_id) from sequences where sample_id in ($sample_id) and clone_id is not NULL and functional=1 group by clone_id")
	flag=0
	for clone in ${clones}; do
		if (($flag==0)); then
			qualified_clones+=($clone)
			flag=1
		else
			if (($clone<$size_threshold)); then
				unset qualified_clones[${#qualified_clones[@]}-1]
			fi
			flag=0
		fi
	done	
done
qualified_clones=($(echo "${qualified_clones[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "${#qualified_clones[@]} clones with at least $size_threshold instance(s) in at least one $feature"

# count instance number and sample number in each feature
for clone in ${qualified_clones[@]}; do
    seq_counts=()
    sample_counts=()
    i=0
    for feat in ${unique_features[@]}; do
        sample_group=$(echo "${feature_samples[$feat]}")
        seq_counts[i]=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select count(*) from sequences where clone_id=$clone and functional=1 and sample_id in ($sample_group)")
        sample_counts[i]=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select count(distinct sample_id) from sequences where clone_id=$clone and functional=1 and sample_id in ($sample_group) ")
        i+=1
    done
    echo -e "$clone\t${seq_counts[@]}" | tr ' ' '\t' >> instanceTable.tsv
    echo -e "$clone\t${sample_counts[@]}" | tr ' ' '\t' >> sampleTable.tsv
done

# calculate cosine similarity
python calCosSim.py

# rename files
output_file1="$subject-$feature-C$size_threshold-instanceTable.tsv"
output_file2="$subject-$feature-C$size_threshold-sampleTable.tsv"
output_file3="$subject-$feature-C$size_threshold-externalSimilarity.tsv"
mv instanceTable.tsv $output_file1
mv sampleTable.tsv $output_file2
mv externalSimilarity.tsv $output_file3



