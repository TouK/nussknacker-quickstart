#!/bin/sh

# Ten skrypt tworzy inicjalną wersję tablicy agregatów, używając m.in. templejtu rafmCacheTemplate.
# Tak stworzona tablica może być modyfikowana poleceniem ALTER TABLE. 

# TO DO:
#   dostrojenie tej tablicy pod kątem wydajności, np. PRIMARY KEY, AFFINITY KEY

/opt/ignite/apache-ignite/bin/sqlline.sh -u 'jdbc:ignite:thin://ignite' -n ignite -p ignite -f /nfs/sampleScenarios/aggregates/customer-aggregates.sql
