# Welcome To My Dotfiles

This repository aims to serve all my go-to configurations. This includes various app configurations, theming, and useful shell scripts that are either tightly integrated with my setup, or aren't significant enough to warrant their own repository.

You are more than welcome to borrow any of my configurations for your own set ups.

## Synopsis of my setup

This dotfiles is mainly tailored for a CachyOS setup using labwc with Dank Material Shell. There is additional Nix configuration files for an alternative desktop setup, though they need to be updated.

#### Screenshots

A [custom screenshotting utility](scripts/dms-screenshot.sh) uses the built in Dank Material Shell screenshotting tool, but it does a couple extra steps using ImageMagick to save the file as a JPEG XL instead of a PNG for file space reasons.

#### Davinci Transcoding Scripts

Using Davinci Resolve, especially the free edition, can be a pain in the ass, especially if you don't have a graphics card new enough to take advantage of AV1 hardware accelerated encoding. Or you may simply just want a smoother experience when editing. My import script, [davincivideo](scripts/davincivideo.sh), can easily take care of all of this by transcoding your videos into production ready formats, making it much easier to edit on Linux. The export script, [davincideliver](scripts/davincideliver.sh), makes it much easier to transcode your final render into a much smaller deliverable format.

WARNING: These codecs don't use inter-frame compression, so make sure you have the proper hard drive space when working with these files 