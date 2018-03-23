# script that will only uppdate changed sources in anmalan
FROM=anmalan-google-form
TO=${HOME}/public_html/scout

SRC=$(notdir $(wildcard ${FROM}/*))


all: ${SRC:%=${TO}/%}
${SRC:%=${TO}/%}: ${TO}/% : ${FROM}/%
	cp ${FROM}/$* ${TO}/$*

