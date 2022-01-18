#!/bin/bash

i=0
v=0
r=0

while getopts ivr opt
do
    case $opt in
        i) i=1 ;;
        v) v=1 ;;
        r) r=1 ;;
    esac
done

mkdir -p ~/deleted

shift $(($OPTIND - 1))

read -a pathList <<< $*

if [ ${#pathList[@]} -eq 0 ]; then
    echo "remove: missing operand"
    exit 1
fi

function rmFile() {
    pathAbs=$1

    if [ $pathAbs = ~/project/remove ]; then
        echo "Attempting to delete remove - operation aborted"
        exit 1
    fi


    inode=$(stat -c%i $pathAbs)
    file=$(basename $pathAbs)
    fileDel=$(basename $pathAbs)\_$inode

    echo $file $fileDel

    removed=0

    if [ $i -eq 1 ]; then
        read -p "Do you want to remove file $file?" rmopt
        case $rmopt in
            y | Y | yes)
                mv $pathAbs ~/deleted/$fileDel
                touch -a ~/.restore.info
                echo $fileDel:$pathAbs >> ~/.restore.info
                removed=1 ;;
            *) ;;
        esac
    else
        mv $pathAbs ~/deleted/$fileDel
        touch -a ~/.restore.info
        echo $fileDel:$pathAbs >> ~/.restore.info
        removed=1
    fi

    if [ $v -eq 1 ] && [ $removed -eq 1 ]; then
        echo "File $file removed!"
    fi
}

if [ $r -eq 1 ]; then
    #echo "Recursive!"
    for path in ${pathList[@]}
    do
        PathAbs=$(readlink -m $path)

        if [ -f $PathAbs ]; then
            #echo "Try to remove file $PathAbs!"
            rmFile $PathAbs
        elif [ -d $PathAbs ]; then
            read -a allFilesInDir <<< $(find $PathAbs -type f)
            echo ${allFilesInDir[@]}

            for file in ${allFilesInDir[@]}
            do
                rmFile $file
            done

            rm -r $PathAbs

            if [ $v -eq 1 ]; then
                echo "Directory $PathAbs removed!"
            fi

        fi
    done

else
    for file in ${pathList[@]}
    do
        if [ -d $file ]; then
            echo "remove: cannot remove \`$file\': Is a directory"
            exit 1
        elif [ ! -f $file ]; then
            echo "remove: cannot remove \`$file\': No such file or directory"
            exit 1
        fi

        pathAbs=$(readlink -m $file)

        rmFile $pathAbs

    done
fi