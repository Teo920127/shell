file=`dirname "${0}"`
mkdir "$file/../program/mod_bw"
tar -xzvf "$file/../program/mod_bw-0.92.tgz" -C "$file/../program/mod_bw"
apxs -i -a -c "$file/../program/mod_bw/mod_bw.c"
