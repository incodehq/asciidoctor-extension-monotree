RELEASE_VERSION=$1
shift
SNAPSHOT_VERSION=$1
shift
KEYID=$1
shift
PASSPHRASE=$*

if [ ! "$RELEASE_VERSION" -o ! "$SNAPSHOT_VERSION" -o ! "$KEYID" -o ! "$PASSPHRASE" ]; then
    echo "usage: $(basename $0) [release_version] [snapshot_version] [keyid] [passphrase]" >&2
    exit 1
fi


echo ""
echo "sanity check (mvn clean install -T1C -o)"
echo ""
mvn clean install -T1C -o >/dev/null
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi



echo ""
echo "releasing (mvn clean deploy -P release)"
echo ""
mvn clean deploy -P release -Dpgp.secretkey=keyring:id=$KEYID -Dpgp.passphrase="literal:$PASSPHRASE"
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi


echo ""
echo "bumping version to $SNAPSHOT_VERSION"
echo ""
sh ./bumpver.sh $SNAPSHOT_VERSION
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi
