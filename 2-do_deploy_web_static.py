#!/usr/bin/python3
# Fabfile to generates a .tgz archive from the contents of web_static.
import os.path
from datetime import datetime
from fabric.api import local

env.hosts = ['34.231.122.141', '3.236.208.134']
env.user = 'ubuntu'

def do_pack():
    """Create a tar gzipped archive of the directory web_static."""
    dt = datetime.utcnow()
    file = "versions/web_static_{}{}{}{}{}{}.tgz".format(dt.year,
                                                         dt.month,
                                                         dt.day,
                                                         dt.hour,
                                                         dt.minute,
                                                         dt.second)
    if os.path.isdir("versions") is False:
        if local("mkdir -p versions").failed is True:
            return None
    if local("tar -cvzf {} web_static".format(file)).failed is True:
        return None
    return file


def do_deploy(archive_path):
    """deploy archive file

    Args:
        archive_path (string): path to archived file

    Returns:
        _type_: boolean
    """

    if not os.path.isfile(archive_path):
        return False

    name = archive_path.split('/')[-1][:-7]

    if put(archive_path,"/tmp/").failed:
        return False
    if run("tar -xzf {} -C data/web_static/releases/{}".format(archive_path,name)).failed:
        return False

    if run("rm {}".format(archive_path)).failed:
        return False

    if run("rm /data/web_static/current").failed:
        return False

    if run("ln -sf /data/web_static/releases/{} /data/web_static/current".format(name)).failed:
        return False

    return True
