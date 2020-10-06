# docker-remux-box

An All-in-One docker container to REMUX Blu-Ray based on [lsiobase/ubuntu:focal](https://github.com/linuxserver/docker-baseimage-ubuntu).

## Embedded tools

- `bdinfo` : [BDInfoCLI-ng (fork by zoffline)](https://github.com/zoffline/BDInfoCLI-ng) running with `mono`.
- `eac3to` : [eac3to](https://forum.doom9.org/showthread.php?t=125966) running with `wine` (works most of the time, but some issues can appear due wine).
  - `libFLAC` : [FLAC](https://xiph.org/flac/) (I'll try to keep libFLAC up-to-date).
- `mkvmerge`, `mkvinfo`, `mkvextract`, `mkvpropedit` : [mkvtoolnix](https://mkvtoolnix.download/).
- `mediainfo` : [mediainfo](https://mediaarea.net/en/MediaInfo).
- `ffmpeg` : [ffmpeg](https://ffmpeg.org/).
- `sox` : [sox](http://sox.sourceforge.net/).

## Limitations

- Occasionally `eac3to` had strange issues when it's running trough `wine` (only way to run it on linux without VM). So be particularly careful about his logs. :warning:
- `bdinfo` or `eac3to` can't be use on .iso files.

## Usage

Start the container and run bash inside. The container will be deleted after the exit.
```shell
docker run -it --rm \
  --name=remux-box \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -v <path to raws>:/raws \
  hummingbirdy2/remux-box bash /switch-user.sh
```
> `/switch-user.sh` is just a script to switch to the defaut user (need `PUID` and `PGID`). If you prefer to be root, run `bash` alone.

Move to your working directory.
```shell
cd /raws
```

## Parameters

| Parameter | Function |
| :----: | --- |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-v /raws` | Path to works with raws. |

### User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```shell
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Known Issues

### 2 wine errors appear at the launch of eac3to

```log
0009:err:winediag:nodrv_CreateWindow Application tried to create a window, but no driver could be loaded.
0009:err:winediag:nodrv_CreateWindow Make sure that your X server is running and that $DISPLAY is set correctly.
```

Don't worry about it, eac3to tried to create a window and it's impossible in this configuration.
By the way, if anyone know the magic trick to avoid this error feel free to open an issue. And yes I try `wineconsole` and `WINEDEBUG=-all` is not a solution :wink:
