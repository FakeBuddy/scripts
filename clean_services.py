#!/usr/bin/env python

'''
	The script deletes old versions of deployed services by name pattern
	Directory name example: ServiceName_1.0.1.75
	Script sorts directories by version number and
	deletes all directories except last 3 with the latest versions
'''

import argparse
import re
import os
import shutil
import warnings


def main():
    example_text = '''example:
        python clean_services.py '/opt/app' Service
    '''
    parser = argparse.ArgumentParser(prog="clean_services",
                                     description="Deletes old versions of deployed services",
                                     epilog=example_text,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("appdir", help="applications directory that needs to be cleaned")
    parser.add_argument("appname", help="application search pattern like 'Service'")
    args = parser.parse_args()
    appdir = args.appdir
    appname = args.appname

    app_version = r'\d+\.\d+\.\d+\.\d+'
    app_pattern = re.compile(appname + "_" + app_version)

    def get_apps(pattern, directory):
        return filter(pattern.match, os.listdir(directory))

    def sort_versions(obj):
        """
            Sort the given list by version number.
        """
        # Get splited List item and convert digit blocks to Int
        convert = lambda text: int(text) if text.isdigit() else text
        # Split List item by block of digits and the rest
        alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]
        # Return List sorted by version number
        return sorted(obj, key=alphanum_key)

    app_list = get_apps(app_pattern, appdir)
    apps_sorted = sort_versions(app_list)

    if not apps_sorted:
        print("No items match your search")
        warnings.warn("No items match your search or check your input")
    elif len(apps_sorted) > 3:
        print('Deleting the following old releases:')
        for x in apps_sorted[:-3]:
            print(x)
            shutil.rmtree(os.path.join(appdir, x))
        print('\nCurrent releases:')
        for i in sort_versions(get_apps(app_pattern, appdir)):
            print(i)
    else:
        print("This directory is in clean state")
        for i in apps_sorted:
            print(i)


if __name__ == "__main__":
    main()