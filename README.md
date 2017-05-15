Cosine similarity
=============

Bochao Zhang

This script will read data from immuneDB and calculate the cosine similarities between samples of different charateristic.<br>

## Usage

```
-d name of database
-s name of subject
-f field of the columns used to separate data
-t size threshold, lower bound clone size, see methods below
```
For example

```
bash calCosSim.sh -d lp11 -s D207 -f tissue -t 20
```
will calculate the cosine similarities between tissue samples of subject D207 from database lp11, using only clones that have at least 20 instances in at least one tissue

** Note: you will need permission to access databases, replace your username and pwd in security.cnf. If you want to use it and do not have access, please contact mailto:**

## Methods
### Instance
We considered clone size to be the sum of the number of uniquely mutated sequences and all the different instances of the same unique sequence that are found in separate sequencing libraries. We refer to this hybrid clone size measure as “unique sequence instances”.

### Lower bound clone size
When we say two compartments overlap or lack overlap, it is important to make sure we have enough coverage of the whole scenario so the lack of overlaps is not a result of under-sampling. Only clones with larger sizes will be sufficiently sampled to demonstrate overlap or lack of overlap. This lower bound clone size is defined as at least X instances in at least compartment. And they are generally referred to as $C_x$ clones, where X denotes the lower bound clone size.

### Calculation
The cosine similarity between different compartments are calculated as:

$$ \frac{\sum_{i=1}^{n} A_iB_i}{\sqrt{\sum_{i=1}^{n} A_i^2}\sqrt{\sum_{i=1}^{n} B_i^2}} $$

where $A_i$ and $B_i$ are components of vectors A and B, respectively. Each attribute in vector A or B represents the number of samples in compartment 1 and compartment 2, respectively.

The value of cosine similarity will be in range of [0,1], with 0 meaning no similarity at all and 1 meaning completely similarity. 


## Output files
The code will out put three files, each with prefix:
[subject]-[feature]-[CX]-
in which X denotes the lower bound clone size. The three files are:


**instanceTable.tsv**: each row is a clone, starts with a uniquely assigned clone id, and each column is the number of total instances in each compartment.

**sampleTable.tsv**: each row is a clone, starts with a uniquely assigned clone id, and each column is the number of samples in each compartment.

**externalSimilarity.tsv**: a symmetrical table with each compartment on both rows and columns. Each cell is the cosine similarity between compartment of row and column. Cells on diagonal will always have value of 1.



