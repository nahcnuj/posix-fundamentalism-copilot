/inet / {
    for (i = 1; i <= NF; i++) {
        if ($i == "inet") {
            addr = $(i+1)
            sub(/^addr:/, "", addr)
            sub(/\/.*/, "", addr)
            if (addr !~ /^127\./) {
                print addr
            }
        }
    }
}
