An AWK program that 'dequotes' CSV fields for various defined/configured record
types.

Configuration of record types and the fields that are to be dequoted is placed 
in the `dequote-config` file, and should be a pair of values in the format
`record_type=comma separated field indexes`. For example:

    # TYPE_1 records to dequote second and fourth fields.
    TYPE_1=2,4
    # TYPE_2 records to dequote third, fourth and fifth fields.
    TYPE_2=3,4,5

The configuration file should be the first file in the list to process.

The program accepts a single, optional, argument `RECORD_TYPE_INDEX` which
should be the numerical index of which input file field the record type
identifier can be found. If not supplied it defaults to the first field.

Usage:

    awk -v RECORD_TYPE_INDEX=1 -f dequote.awk dequote-config test_data.csv

Where the `dequote-config` content is as the example above and the 
`test_data.csv` file contains:

    "TYPE_1","a","b","c","d","e"
    "TYPE_2","f","g","h","i","j"
    "TYPE_1","\"k\"","l","m","n","o"
    "TYPE_3","k","l","m","n","o

The result is:

    "TYPE_1",a,"b",c,"d","e"
    "TYPE_2","f",g,h,i,"j"
    "TYPE_1",\"k\","l",m,"n","o"
    "TYPE_3","k","l","m","n","o"

For more information, both `debug-config` and `dequote.awk` are commented.
