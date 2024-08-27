#!/bin/bash -e

pg_isready -d mocks -U mocks > /dev/null
