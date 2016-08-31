# infect-import

imports data obtained from a denormalized mysql database into the normalized
data structure of the infect application





# import process

1. the file is fetched from a datasource and provided as a binary stream
2. the binary stream is converted to an internal stream format
3. the stream is validated using some mechanism
4. the validated stream is stored in the db


the insternal stream data structure is some sort of object stream (not a node.js stream).

