# Program that does an 'in place' removal of quotes around specific CSV file
# fields.
#
# The CSV can be comprised of multiple record types, and the record type
# identifier should be one of the record fields. An example record:
#
#     "TYPE_1","a","b","c","d","e"
#
# The resulting record (where fields 2 and 4 are configured to be dequoted via
# the 'dequote-config' file) would then be:
#
#     "TYPE_1",a,"b",c,"d","e"
#
# It is assumed that all input file fields are double quoted.
#
# Program can take a single argument, RECORD_TYPE_INDEX, that specifies which
# record field contains a record type value. Defaults to 1, if not specified.
#
# The first file specified to be processed should be 'dequote-config' whose 
# contents should be name value pairs of record type and field indexes to
# dequote. For example:
#
#     TYPE_1=2,4
#     TYPE_2=3,4,5
#
# Example usages:
#
#     awk -f dequote.awk dequote-config test_data.csv
#     awk -v RECORD_TYPE_INDEX=3 -f dequote.awk dequote-config test_data.csv
#
BEGIN {
    FS=","
    OFS=","

    # Set record field index of where to look for its record type
    type_index = record_type_index()
}
{
    # Load configuration, from the 'dequote-config' file, of which record type
    # field indexes should have quotes removed
    if (NR == FNR) {
        if ($0 !~ /^#|^$/) {
            split($0, nvp, "=");
            config[nvp[1]] = nvp[2];
            next;
        }
    }

    # Remove the record type field start/end quotes, to aid config array lookup
    record_type = dequote($type_index)

    # If we've set some config for the record type...
    if (record_type in config) {
        # ...split the record type field indexes string into an array 
        split(config[record_type], indexes, ",")
        # For each index, dequote that field in the current record
        for (i in indexes) {
            $indexes[i] = dequote($indexes[i])
        }
    }
    
    # Output the modified record to a .tmp file
    if (FILENAME != "dequote-config") {
        print $0 > FILENAME".tmp"
    }
}
END {
    # Move the .tmp to replace the original file
    if (FILENAME != "dequote-config") {
        system("mv " FILENAME".tmp " FILENAME)
    }
}

# Return field index of where to find record type
function record_type_index() {
    # Set default to be first field (1-based array)
    type_index = 1
   
    # If the argument was supplied, use it 
    if (RECORD_TYPE_INDEX > 0) {
        type_index = RECORD_TYPE_INDEX
    }

    return type_index
}

# Remove start/end quotes from a string
function dequote(field) {
    return gensub(/^"(.+)"$/, "\\1", "g", field)
}
