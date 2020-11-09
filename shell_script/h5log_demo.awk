#!/bin/awk -f
#运行前
BEGIN {
    printf "---------------------------------------------\n"
    SUBSEP="#"
    #arr[0]=0
}
#运行中
{
    #math+=$3
    #english+=$4
    #computer+=$5
    #printf "%-6s %-6s %4d %8d %8d %8d\n", $1, $2, $3,$4,$5, $3+$4+$5
    #18/Sep/2016:01:28:2
    ip=substr($1,2, length($1) -2)
    time=substr($3,2, length($3) -2)
    split(time, time_array, "/")
    #print time_array[1], time_array[2]
    time_real=sprintf("%04d-%02d-%02d", substr(time_array[3], 1, 4),(index("JanFebMarAprMayJunJulAugSepOctNovDec",time_array[2])+2)/3,time_array[1])
    print ip, time, time_real
    _tt="h5_ip_date/"
    file_path=(_tt""time_real)
    print file_path
    h5_ip = sprintf("%s %s", time_real, ip)
    system("echo \"" h5_ip "\" >> " file_path)
    arr[ip, time_real]++
}
#运行后
END {
    printf "---------------------------------------------\n"
    #for(i in arr) {
    #    split(i, _arr, SUBSEP)
    #    print _arr[2], _arr[1], arr[i]
    #} 
}
