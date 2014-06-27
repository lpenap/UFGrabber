UFGrabber
=========

An image grabber for the User Friendly comic strip.

Installation
============

If you have executed perl scripts before, just install all the required packages through CPAN, may need to install perl-magick too according to your OS.

Config
======

Modify the initial date and the final date to start grabbing.

How it works
============

For each date, it will construct the comic' url for that day and fetch the html contents. Then it looks the html code for a regexp match of the desired image file and grabs it.
The script will store each image with a human readable filename and extract the GIF frames if any.
