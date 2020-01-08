curl -s http://api.icndb.com/jokes/random/ | python -c 'import sys, json; print "\n"+json.load(sys.stdin)["value"]["joke"]+"\n\n"'
