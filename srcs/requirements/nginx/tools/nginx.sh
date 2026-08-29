#!/bin/bash

until nc -z wordpress 9000; do
    echo "test test  WordPress khedaam ???..."
    sleep 2
done


exec nginx -g "daemon off;"
