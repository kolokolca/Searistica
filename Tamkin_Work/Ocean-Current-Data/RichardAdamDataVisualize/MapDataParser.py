if __name__ == "__main__":
    string = ""
    processed = {}
    with open("mapData2.dat") as infile:
        i = 0;
        for line in infile:
            print line
            if( i == 0):
                continue
            data = line.split(' ')
            x = data[0]
            y = data[1]
            u = data[2]
            v = data[3]
            s = x + "," + y + "," + str(u) + "," + v +"\n"
            string += s
            i = i + 1
            print i
    fileObject = open("forMatlab.txt", "wb")
    fileObject.write(string);
    fileObject.close()
    