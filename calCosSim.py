def calculateExternal():
    header, matrix = readTSV('sampleTable.tsv')
    del header[0]
    matrix = zip(*matrix)
    output_file = open('externalSimilarity.tsv','w')
    output_file.write('\t' + '\t'.join(header) + '\n')

    for i in range(len(header)):
        output_file.write(header[i])
        for j in range(len(header)):
            sim = calculateCosineSimilarity(map(float,matrix[i]), map(float,matrix[j]))
            output_file.write('\t' + str(sim))
        output_file.write('\n') 
            
    output_file.close()


def calculateCosineSimilarity( a,b ):
    l = len(a)
    dots = 0
    for i in range(l):
        dots += a[i] * b[i]

    magnitude1 = 0
    for i in range(l):
        magnitude1 += a[i] ** 2
    magnitude1 = magnitude1 ** 0.5    
    
    magnitude2 = 0
    for i in range(l):
        magnitude2 += b[i] ** 2
    magnitude2 = magnitude2 ** 0.5    

    return dots / (magnitude1 * magnitude2)


def readTSV( input_file ):
    import csv
    
    with open(input_file,'rb') as tsvin:
        tsvin = csv.reader(tsvin, delimiter='\t')
        array = []
        for row in tsvin:
            array.append(filter(None, row))
    header = array[0]
    matrix = array[1:]

    return header, matrix
       

if __name__ == '__main__':
    calculateExternal()
