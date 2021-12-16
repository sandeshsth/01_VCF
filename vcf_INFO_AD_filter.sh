#!/bin/bash
​
if [ $# -ne 5 ]
then
    echo -e "USAGE:\n$0 file.vcf AD_positionIn_INFO >=total_filteredDP <=total_filteredDP Both_Allele_should_be_at_least\n"
    echo -e "AD position in INFO"
    echo -e "DP is raw read depth.\nAD is filtered read depth presence as REF,ALT. Filtered total depth is REF+ALT of AD."
    echo -e "\n$0 file.vcf 2 10 20 3 means:\nTotal filtered depth is >=10 and <=20\nREF and ALT both should have the depth of at least 3."
    exit 0
fi
​
cat <(head -1000 $1 | grep '^#') <(grep -v "^#" $1 | awk -v InfoAdPos="$2" -v lowFilteredDP="$3" -v highFilteredDP="$4" -v BothAllele="$5" '{split($8,info,";");split(info[InfoAdPos],ad,"=");split(ad[2],adn,","); total=adn[1]+adn[2]; if (total >= lowFilteredDP && total <= highFilteredDP && adn[1] >= BothAllele && adn[2] >=BothAllele){print $0}}') > FDP.l${3}.h${4}.AD${5}_${1}



