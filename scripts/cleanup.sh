#!/bin/bash

kubectl delete clusterpolicy --all
helm uninstall vm
helm uninstall vmagent
